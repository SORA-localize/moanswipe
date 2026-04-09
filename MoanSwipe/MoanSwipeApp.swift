//
//  MoanSwipeApp.swift
//  MoanSwipe
//
//  Created by クワシマソウヘイ on 2026/04/09.
//

import AppKit
import SwiftUI

@main
struct MoanSwipeApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            Toggle("Enabled", isOn: $appState.isEnabled)

            Button("Play Test Sound") {
                appState.playTestSound()
            }
            .disabled(!appState.isEnabled)

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            Text("MoanSwipe")
        }
        .menuBarExtraStyle(.menu)
    }
}
