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
    private var player: AVAudioPlayer?

    func playTestClip() {
        guard let url = Bundle.main.url(forResource: "anime-moan-3", withExtension: "wav", subdirectory: "Resources") ??
                Bundle.main.url(forResource: "anime-moan-3", withExtension: "wav") else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            self.player = player
        } catch {
            self.player = nil
        }
    }
}
