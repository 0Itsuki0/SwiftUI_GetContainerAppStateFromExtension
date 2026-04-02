# SwiftUI: Get Container APp State from Keyboard Extension

A demo of determining whether the container app (or a specific feature in the app) is running or not from an extension.

## Basic Approach

**App Group + file lock**

1. Create A shared file with App Group
2. When the container starts the feature, open the file and acquires the lock with open(_:_:options:permissions:retryOnInterrupt:) on FileDescriptor
3. When the container app ends the feature, release the lock by closing the file descriptor. 
4. When the extension needs to find whether the app (or the feature) is running or not, try to open the same file and get the lock. If lock succeeded, then the container app is dead or the feature is not running. Otherwise, the feature is running!


For more details, please refer to my blog [SwiftUI: Is My Container App (Or App's xxx Feature) Running? Asked By My Keyboard Extension.](https://medium.com/@itsuki.enjoy/swiftui-is-my-container-app-or-apps-xxx-feature-running-asked-by-my-keyboard-extension-d2644fed2820)

![](./demo.gif)
