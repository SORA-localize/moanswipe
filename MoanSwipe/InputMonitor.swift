//
//  InputMonitor.swift
//  MoanSwipe
//
//  Created by クワシマソウヘイ on 2026/04/09.
//

import AppKit
import Foundation

final class InputMonitor {
    private var globalMonitor: Any?
    private var localMonitor: Any?

    func startMonitoring(
        onPrimaryClick: @escaping () -> Void,
        onScroll: @escaping () -> Void
    ) {
        stopMonitoring()

        globalMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .scrollWheel]
        ) { event in
            DispatchQueue.main.async {
                switch event.type {
                case .leftMouseDown:
                    onPrimaryClick()
                case .scrollWheel:
                    onScroll()
                default:
                    break
                }
            }
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.leftMouseDown, .scrollWheel]
        ) { event in
            switch event.type {
            case .leftMouseDown:
                onPrimaryClick()
            case .scrollWheel:
                onScroll()
            default:
                break
            }
            return event
        }
    }

    func stopMonitoring() {
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }

        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }
    }

    deinit {
        stopMonitoring()
    }
}
