//
//  EventStoreManager.swift
//  Today_3x3
//
//  Created by kidstyo on 2024/2/11.
//

import Foundation
import EventKit

@MainActor
class EventStoreManager: ObservableObject {
    @Published var writableCalendars: [EKCalendar] = []
    let ekStore = EKEventStore()

    var isFullAccessAuthorized: Bool {
        if #available(iOS 17.0, *) {
            EKEventStore.authorizationStatus(for: .event) == .fullAccess
        } else {
            // Fall back on earlier versions.
            EKEventStore.authorizationStatus(for: .event) == .authorized
        }
    }

    /*
        Listens for event store changes, which are always posted on the main thread. When the app receives a full access authorization status, it
        fetches all events occuring within a month in all the user's calendars.
    */
    func listenForCalendarChanges() async {
        let center = NotificationCenter.default
        let notifications = center.notifications(named: .EKEventStoreChanged).map({ (notification: Notification) in notification.name })

        for await _ in notifications {
            guard isFullAccessAuthorized else { return }
            await self.fetchCalendars()
        }
    }

    func fetchCalendars() async{
        let calendars = ekStore.calendars(for: .event)
        self.writableCalendars = calendars.filter { $0.allowsContentModifications }
    }
}
