//
//  EventStore.swift
//  Today_3x3 (iOS)
//
//  Created by kidstyo on 2023/9/25.
//

import Foundation
import EventKit

class EventStore {
    static let shared = EventStore()
    let ekStore = EKEventStore()

    var isFullAccessAuthorized: Bool {
        if #available(iOS 17.0, *) {
            EKEventStore.authorizationStatus(for: .event) == .fullAccess
        } else {
            // Fall back on earlier versions.
            EKEventStore.authorizationStatus(for: .event) == .authorized
        }
    }

    /// Prompts the user for full-access authorization to Calendar.
    private func requestFullAccess() async throws -> Bool {
        print("requestFullAccess")
        if #available(iOS 17.0, *) {
            return try await ekStore.requestFullAccessToEvents()
        } else {
            // Fall back on earlier versions.
            return try await ekStore.requestAccess(to: .event)
        }
    }

    /// Verifies the authorization status for the app.
    func verifyAuthorizationStatus() async throws -> Bool {
        print("verifyAuthorizationStatus")

        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .notDetermined:
            return try await requestFullAccess()
        case .restricted:
            throw EventStoreError.restricted
        case .denied:
            throw EventStoreError.denied
        case .fullAccess:
            return true
        case .writeOnly:
            throw EventStoreError.upgrade
        @unknown default:
            throw EventStoreError.unknown
        }
    }
}
