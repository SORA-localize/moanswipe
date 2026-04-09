//
//  AppState.swift
//  MoanSwipe
//
//  Created by クワシマソウヘイ on 2026/04/09.
//

import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var isEnabled = true

    let audioPlayer = AudioPlayer()

    func playTestSound() {
        guard isEnabled else { return }
        audioPlayer.playTestClip()
    }
}
