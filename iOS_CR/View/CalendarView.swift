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
    let ekStore = EKEventStore()

    @State private var authorizationStatus: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)

    @State var todaysEvents = [EKEvent]()

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

                if let defaultCalendarForNewEvents = ekStore.defaultCalendarForNewEvents{
                    Text("defaultCalendarForNewEvents")
                    EventCalendar(ca: defaultCalendarForNewEvents)
                }
                
                if let defaultCalendarForNewReminders = ekStore.defaultCalendarForNewReminders(){
                    Text("defaultCalendarForNewReminders")
                    EventCalendar(ca: defaultCalendarForNewReminders)
                }

                DisclosureGroup(
                    content: {
                        ForEach(storeManager.writableCalendars, id:\.self){ca in
                            EventCalendar(ca: ca)
                        }
                    },
                    label: {
                        Text("Calendars: \(storeManager.writableCalendars.count)")
                    }
                )

                Section {
                    ForEach(todaysEvents, id: \.eventIdentifier) { event in
                        EventItem(event)
                            .contextMenu {
                                Button {
                                    removeEvent(uId: event.calendarItemExternalIdentifier)
                                    addEvent(title: "title \(Int.random(in: 0...1000))", notes: "notes \(Int.random(in: 0...1000))", start: Date().addingTimeInterval(-Double(Int.random(in: 0..<3600))), end: Date().addingTimeInterval(TimeInterval(Int.random(in: 0..<3600))), location: "location \(Int.random(in: 0...1000))", calendar: storeManager.writableCalendars[Int.random(in: 0..<storeManager.writableCalendars.count)])
                                    refresh()
                                } label: {
                                    Text("Update")
                                }
                                
                                Button(role: .destructive) {
                                    removeEvent(uId: event.calendarItemExternalIdentifier)
                                    refresh()
                                } label: {
                                    Text("Delete")
                                }
                            }
                    }
                } header: {
                    Text("Events")
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .principal) {
                    Text("Calendar")
                        .fontDesign(.serif)
                        .fontWeight(.bold)
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        Task{
                            addEvent(calendar: nil)
                            refresh()
                        }
                    }, label: {
                        Text("Plus")
                    })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        refresh()
                    }, label: {
                        Text("Refresh")
                    })
                }
            })
        }
        .task{
            do {
                _ = try await eventStore.verifyAuthorizationStatus()
                authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                await storeManager.fetchCalendars()
                await storeManager.listenForCalendarChanges()
                todaysEvents = eventStore.events(for: selectDate, calendars: nil)
            } catch {
                print("Authorization failed. \(error.localizedDescription)")
            }
        }
        .onChange(of: selectDate) { oldValue, newValue in
            todaysEvents = eventStore.events(for: selectDate, calendars: nil)
        }
    }
    
    func refresh(){
        todaysEvents = eventStore.events(for: selectDate, calendars: nil)
    }
    
    func addEvent(title: String = "title", notes: String = "notes", start: Date = Date(), end: Date = Date().addingTimeInterval(3600), location: String = "localtion", calendar: EKCalendar?){
        Task{
            let ekEvent = EKEvent(eventStore: ekStore)
            ekEvent.title = title
            ekEvent.location = location
            ekEvent.startDate = start
            ekEvent.endDate = end
            ekEvent.calendar = calendar ?? ekStore.defaultCalendarForNewEvents
            try ekStore.save(ekEvent, span: .thisEvent)
            
            ekEvent.notes = notes + "\n" + ekEvent.calendarItemExternalIdentifier
            try ekStore.save(ekEvent, span: .thisEvent)
        }
    }
    
    func removeEvent(uId: String){
        if let ekEvent = ekStore.calendarItems(withExternalIdentifier: uId).first as? EKEvent {
            do {
                try ekStore.remove(ekEvent, span: .thisEvent)
            } catch {
                print("EventStore removeScheduleEvent \(error.localizedDescription)")
            }
        } else {
            print("EventStore removeScheduleEvent Event not found")
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
