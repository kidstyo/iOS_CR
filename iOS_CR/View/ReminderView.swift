//
//  ReminderView.swift
//  iOS_CR
//
//  Created by kidstyo on 2024/3/8.
//

import SwiftUI
import EventKit

struct ReminderView: View {
    private var reminderStore: ReminderStore { ReminderStore.shared }

    @State private var authorizationStatus: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .reminder)

    var body: some View {
        List {
            Text(authorizationStatus.desc)
//                .foregroundStyle(isFullAccessAuthorized ? .green : .red)
        }
        .onAppear(perform: {
            prepareReminderStore()
        })
    }

    // 请求权限
    func prepareReminderStore() {
        Task {
            do {
                let response = try await reminderStore.verifyAuthorizationStatus()
                authorizationStatus = EKEventStore.authorizationStatus(for: .reminder)

//                reminders = try await reminderStore.readAll()
//                NotificationCenter.default.addObserver(self, selector: #selector(eventStoreChanged(_:)), name: .EKEventStoreChanged, object: nil)
            } catch TodayError.accessDenied, TodayError.accessRestricted {
                #if DEBUG
//                reminders = Reminder.sampleData
                print("Error! accessRestricted")
                #endif
            } catch {
//                showError(error)
                print("Error! \(error)")
            }
//            updateSnapshot()
        }
    }
}

#Preview {
    ReminderView()
}
