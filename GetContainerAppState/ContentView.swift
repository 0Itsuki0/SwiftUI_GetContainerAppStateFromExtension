//
//  ContentView.swift
//  GetContainerAppState
//
//  Created by Itsuki on 2026/03/31.
//

import SwiftUI

struct ContentView: View {
    @State private var isFeatureRunning: Bool = false
    @State private var appFeatureStateManager = AppFeatureStateManager()
    var body: some View {
        VStack(spacing: 48) {
            Text("Is the feature Running? \(isFeatureRunning ? "Yah!" : "No!")")
                .font(.title2)
                .fontWeight(.semibold)
            
            Toggle(isOn: $isFeatureRunning, label: {
                Text("Some Feature")
            })
            .onChange(of: self.isFeatureRunning, {
                self.isFeatureRunning ? appFeatureStateManager.acquireLock() : appFeatureStateManager.releaseLock()
            })
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.yellow.opacity(0.1))
    }
}
