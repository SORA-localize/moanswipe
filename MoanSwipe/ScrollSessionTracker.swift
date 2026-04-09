//
//  ScrollSessionTracker.swift
//  MoanSwipe
//
//  Created by クワシマソウヘイ on 2026/04/09.
//

import Foundation

@MainActor
final class ScrollSessionTracker {
    enum Stage {
        case idle
        case short
        case sustained
        case intense
    }

    private let sessionTimeout: TimeInterval = 0.35
    private let sustainedThreshold: TimeInterval = 0.9
    private let intenseThreshold: TimeInterval = 1.8

    private(set) var stage: Stage = .idle
    private(set) var sessionStartedAt: Date?
    private(set) var lastEventAt: Date?
    private(set) var eventCount = 0

    private var sessionEndTimer: Timer?

    func registerEvent(at now: Date = Date()) -> AudioPlayer.SoundCategory? {
        defer {
            lastEventAt = now
            scheduleSessionEndTimer()
        }

        guard let sessionStartedAt,
              let lastEventAt,
              now.timeIntervalSince(lastEventAt) <= sessionTimeout else {
            startNewSession(at: now)
            return .scrollShort
        }

        eventCount += 1
        let elapsed = now.timeIntervalSince(sessionStartedAt)

        if elapsed >= intenseThreshold, stage != .intense {
            stage = .intense
            return .scrollIntense
        }

        if elapsed >= sustainedThreshold, stage == .short {
            stage = .sustained
            return .scrollSustained
        }

        return nil
    }

    private func startNewSession(at now: Date) {
        invalidateTimer()
        stage = .short
        sessionStartedAt = now
        lastEventAt = now
        eventCount = 1
    }

    private func endSession() {
        invalidateTimer()
        stage = .idle
        sessionStartedAt = nil
        lastEventAt = nil
        eventCount = 0
    }

    private func scheduleSessionEndTimer() {
        invalidateTimer()

        sessionEndTimer = Timer.scheduledTimer(withTimeInterval: sessionTimeout, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.endSession()
            }
        }
    }

    private func invalidateTimer() {
        sessionEndTimer?.invalidate()
        sessionEndTimer = nil
    }

    deinit {
        sessionEndTimer?.invalidate()
    }
}
