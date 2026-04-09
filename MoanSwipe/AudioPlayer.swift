//
//  AudioPlayer.swift
//  MoanSwipe
//
//  Created by クワシマソウヘイ on 2026/04/09.
//

import AVFoundation
import Foundation

@MainActor
final class AudioPlayer {
    enum SoundCategory: CaseIterable {
        case click
        case scroll
    }

    private struct AudioClip: Equatable {
        let resourceName: String
    }

    private let clipPools: [SoundCategory: [AudioClip]] = [
        .click: [
            AudioClip(resourceName: "click_light_01"),
            AudioClip(resourceName: "click_soft_01"),
            AudioClip(resourceName: "click_sharp_01"),
        ],
        .scroll: [
            AudioClip(resourceName: "scroll_soft_01"),
            AudioClip(resourceName: "scroll_flow_01"),
            AudioClip(resourceName: "scroll_intense_01"),
        ],
    ]

    private var lastPlayedClipByCategory: [SoundCategory: AudioClip] = [:]
    private var player: AVAudioPlayer?

    func play(category: SoundCategory) {
        guard let clip = selectClip(for: category),
              let url = url(for: clip.resourceName) else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            self.player = player
            lastPlayedClipByCategory[category] = clip
        } catch {
            self.player = nil
        }
    }

    func playTestClip() {
        play(category: .click)
    }

    private func selectClip(for category: SoundCategory) -> AudioClip? {
        guard let clips = clipPools[category], !clips.isEmpty else {
            return nil
        }

        if clips.count == 1 {
            return clips[0]
        }

        let lastPlayed = lastPlayedClipByCategory[category]
        let availableClips = clips.filter { $0 != lastPlayed }
        return availableClips.randomElement() ?? clips.randomElement()
    }

    private func url(for resourceName: String) -> URL? {
        Bundle.main.url(forResource: resourceName, withExtension: "wav", subdirectory: "Resources") ??
            Bundle.main.url(forResource: resourceName, withExtension: "wav")
    }
}
