//
//  AppFeatureStateManager.swift
//  GetContainerAppState
//
//  Created by Itsuki on 2026/03/31.
//

import System
import Foundation

let groupId = "group.xxx.xxx"

// MARK: - Implementation with Darwin
// same functions can also be used for checking whether the container app is alive.
// 1. call acquireLock on app launch (never call releaseLock, the lock will be automatically released on app termination)
// 2. check app state from extension by calling isContainerAppFeatureRunning. True if app is running, false otherwise
//final class AppFeatureStateManager {
//    var lockFD: Int32 = -1
//
//    private static let lockFileURL = FileManager.default
//        .containerURL(forSecurityApplicationGroupIdentifier: groupId)?
//        .appendingPathComponent("app.lock")
//
//    private static let fileManager = FileManager.default
//
//    func acquireLock() {
//        guard let url = Self.lockFileURL else {
//            return
//        }
//
//        if !Self.fileManager.fileExists(atPath: url.path()) {
//            Self.fileManager.createFile(atPath: url.path, contents: nil)
//        }
//
//        // Same as performing the following two seperately
//        // 1. open(url.path, O_RDWR) to open the file
//        // 2. acquire the lock with flock(lockFD, LOCK_EX | LOCK_NB)
//        // However, open with O_RDWR | O_EXLOCK | O_NONBLOCK flag is better because with separate open + flock there's a tiny window between the two calls where another process could theoretically interfere.
//        lockFD = open(url.path, O_RDWR | O_EXLOCK | O_NONBLOCK)
//    }
//
//    func releaseLock() {
//        guard lockFD >= 0 else { return }
//        flock(lockFD, LOCK_UN)
//        close(lockFD)
//        lockFD = -1
//    }
//
//    static func isContainerAppFeatureRunning() -> Bool {
//        guard let url = self.lockFileURL else {
//            return false
//        }
//
//        // tries to open the file and acquire the lock.
//        // result:
//        // 0: locking succeed => app container is dead or the feature is not running
//        // 1: locking failed
//        // same as calling
//        // 1. fileDescriptor = open(url.path, O_RDWR)
//        // 2. if fileDescriptor is >= 0, open succeed => app dead/feature not running => return false
//        // 3. try lock the file with flock(fileDescriptor, LOCK_EX | LOCK_NB)
//        // 4. close(fileDescriptor) to release the lock in case it succeed
//        // 5. return result != 0 => failed to lock = someone else holds it = app feature is running
//        let fileDescriptor = open(url.path, O_RDWR | O_EXLOCK | O_NONBLOCK)
//        if fileDescriptor >= 0 {
//            // acquired lock = container app is dead
//            close(fileDescriptor)
//            return false
//        } else {
//            // failed = container app is alive
//            return true
//        }
//    }
//}


// MARK: - Implementation with Swift FileDescriptor
// same functions can also be used for checking whether the container app is alive.
// 1. call acquireLock on app launch (never call releaseLock, the lock will be automatically released on app termination)
// 2. check app state from extension by calling isContainerAppFeatureRunning. True if app is running, false otherwise
final class AppFeatureStateManager {
    var lockFD: FileDescriptor? = nil
    
    private static let lockFileURL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: groupId)?
        .appendingPathComponent("app.lock")

    private static let fileManager = FileManager.default

    func acquireLock() {
        guard let url = Self.lockFileURL else {
            return
        }

        if !Self.fileManager.fileExists(atPath: url.path()) {
            Self.fileManager.createFile(atPath: url.path, contents: nil)
        }

        // open the file and acquires the lock
        lockFD = try? FileDescriptor.open(
            FilePath(url.path),
            .readWrite,
            options: [.exclusiveLock, .nonBlocking, .create],
            permissions: .ownerReadWrite
        )
    }

    func releaseLock() {
        try? lockFD?.close()
        lockFD = nil
    }

    static func isContainerAppFeatureRunning() -> Bool {
        guard let url = self.lockFileURL else {
            return false
        }
        
        do {
            // try to open the file and acquires the lock
            // if not thrown, the lock acquired, ie: app is dead or feature is not running
            let fileDescriptor = try FileDescriptor.open(
                FilePath(url.path),
                .readWrite,
                options: [.exclusiveLock, .nonBlocking]
            )
            try? fileDescriptor.close()
            return false // acquired lock = app is dead or feature is not running
        } catch let error as Errno {
            return error == .wouldBlock // wouldBlock = lock held = app is alive or feature is running
        } catch {
            return false // file doesn't exist or other error = not alive
        }
    }
}
