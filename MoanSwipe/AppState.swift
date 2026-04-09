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

    private let scrollCooldown: TimeInterval = 0.5
    let audioPlayer = AudioPlayer()
    private let inputMonitor = InputMonitor()
    private var lastScrollPlaybackAt: Date?

    init() {
        inputMonitor.startMonitoring(
            onPrimaryClick: { [weak self] in
                self?.playTriggeredSound()
            },
            onScroll: { [weak self] in
                self?.playScrollTriggeredSound()
            }
        )
    }

    func playTestSound() {
        guard isEnabled else { return }
        audioPlayer.playTestClip()
    }

    private func playTriggeredSound() {
        guard isEnabled else { return }
        audioPlayer.playTestClip()
    }

    private func playScrollTriggeredSound() {
        guard isEnabled else { return }

        let now = Date()
        if let lastScrollPlaybackAt, now.timeIntervalSince(lastScrollPlaybackAt) < scrollCooldown {
            return
        }

        lastScrollPlaybackAt = now
        audioPlayer.playTestClip()
    }
}
