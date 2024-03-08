//
//  CalendarView.swift
//  iOS_CR
//
//  Created by kidstyo on 2024/3/8.
//

import SwiftUI
import EventKit

struct CalendarView: View {
    @State private var selectDate: Date = .init()
    @StateObject private var storeManager: EventStoreManager = EventStoreManager()
    private var eventStore: EventStore { EventStore.shared }

    @State private var authorizationStatus: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)

    var isFullAccessAuthorized: Bool {
        if #available(iOS 17.0, *) {
            return authorizationStatus == .fullAccess
        } else {
            // Fall back on earlier versions.
            return authorizationStatus == .authorized
        }
    }

    var body: some View {
        NavigationStack {
            List {
                DatePicker("Select Date", selection: $selectDate, displayedComponents: [.date])

                Button(action: {
                    Task {
                        do {
                            _ = try await eventStore.verifyAuthorizationStatus()
                            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
            //                calendar = eventStore.ekStore.calendar(withIdentifier: selectedCalendarIdentifier)
                            await storeManager.fetchCalendars()
                            await storeManager.listenForCalendarChanges()
                        } catch {
                            print("Authorization failed. \(error.localizedDescription)")
                        }
                    }
                }, label: {
                    Text(authorizationStatus.desc)
                        .foregroundStyle(isFullAccessAuthorized ? .green : .red)
                })

                DisclosureGroup(
                    content: {
                        ForEach(storeManager.writableCalendars, id:\.self){ca in
                            Label {
                                VStack(alignment: .leading, spacing: 5, content: {
                                    Text(ca.title)

                                    Text(ca.description)
                                        .font(.footnote)

                                    Text(ca.calendarIdentifier)
                                        .font(.footnote)
                                })
                            } icon: {
                                Image(systemName: "circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(Color(cgColor: ca.cgColor))
                            }
                        }
                    },
                    label: {
                        Text("Calendars: \(storeManager.writableCalendars.count)")
                    }
                )

                Section {
                    
                } header: {
                    Text("Events")
                }
            }
//            .listStyle(.grouped)
            .toolbar(content: {
                ToolbarItem(placement: .principal) {
                    Text("Calendar")
                        .fontDesign(.serif)
                        .fontWeight(.bold)
                }
            })
//            .navigationBarTitleDisplayMode(.inline)
        }
        .task{
            do {
                _ = try await eventStore.verifyAuthorizationStatus()
                authorizationStatus = EKEventStore.authorizationStatus(for: .event)
//                calendar = eventStore.ekStore.calendar(withIdentifier: selectedCalendarIdentifier)
                await storeManager.fetchCalendars()
                await storeManager.listenForCalendarChanges()
            } catch {
                print("Authorization failed. \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    CalendarView()
}

extension EKAuthorizationStatus{
    var desc: String{
        switch self {
        case .notDetermined:
            return "notDetermined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        case .fullAccess:
            return "fullAccess"
        case .writeOnly:
            return "writeOnly"
        case .authorized:
            return "authorized"
        @unknown default:
            return "@unknown"
        }
    }
}
