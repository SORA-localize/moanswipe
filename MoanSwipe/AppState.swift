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
    private let inputMonitor = InputMonitor()
    private let scrollSessionTracker = ScrollSessionTracker()

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
        audioPlayer.play(category: .click)
    }

    private func playTriggeredSound() {
        guard isEnabled else { return }
        audioPlayer.play(category: .click)
    }

    private func playScrollTriggeredSound() {
        guard isEnabled else { return }
        guard let category = scrollSessionTracker.registerEvent() else { return }
        audioPlayer.play(category: category)
    }
}
