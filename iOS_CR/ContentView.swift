//
//  ContentView.swift
//  iOS_CR
//
//  Created by kidstyo on 2024/3/8.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // iOS 工程正常，否则 mac 无法查询日历
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            ReminderView()
                .tabItem {
                    Label("Reminder", systemImage: "checklist")
                }
        }
    }
}

#Preview {
    ContentView()
}
