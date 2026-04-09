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
    private final class VoiceSlot {
        let clip: AudioClip
        let player: AVAudioPlayer

        init(clip: AudioClip, player: AVAudioPlayer) {
            self.clip = clip
            self.player = player
        }
    }

    enum SoundCategory: CaseIterable {
        case click
        case scroll
    }

    private struct AudioClip: Equatable {
        let resourceName: String
    }

    private let maxConcurrentVoicesPerCategory = 6
    private let preloadedVoicesPerClip = 2

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
    private var voiceSlotsByCategory: [SoundCategory: [VoiceSlot]] = [:]

    init() {
        preloadVoiceSlots()
    }

    func play(category: SoundCategory) {
        guard let clip = selectClip(for: category),
              let voiceSlot = selectVoiceSlot(for: clip, in: category) else {
            return
        }

        voiceSlot.player.currentTime = 0
        voiceSlot.player.play()
        lastPlayedClipByCategory[category] = voiceSlot.clip
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

    private func selectVoiceSlot(for clip: AudioClip, in category: SoundCategory) -> VoiceSlot? {
        guard let voiceSlots = voiceSlotsByCategory[category] else {
            return nil
        }

        if let preferredSlot = voiceSlots.first(where: { $0.clip == clip && !$0.player.isPlaying }) {
            return preferredSlot
        }

        return voiceSlots.first(where: { !$0.player.isPlaying })
    }

    private func preloadVoiceSlots() {
        var preloadedVoiceSlots: [SoundCategory: [VoiceSlot]] = [:]

        for (category, clips) in clipPools {
            var voiceSlots: [VoiceSlot] = []

            for clip in clips {
                guard let url = url(for: clip.resourceName) else {
                    continue
                }

                for _ in 0..<preloadedVoicesPerClip {
                    guard voiceSlots.count < maxConcurrentVoicesPerCategory else {
                        break
                    }

                    do {
                        let player = try AVAudioPlayer(contentsOf: url)
                        player.prepareToPlay()
                        voiceSlots.append(VoiceSlot(clip: clip, player: player))
                    } catch {
                        continue
                    }
                }
            }

            preloadedVoiceSlots[category] = voiceSlots
        }

        voiceSlotsByCategory = preloadedVoiceSlots
    }

    private func url(for resourceName: String) -> URL? {
        Bundle.main.url(forResource: resourceName, withExtension: "wav", subdirectory: "Resources") ??
            Bundle.main.url(forResource: resourceName, withExtension: "wav")
    }
}
