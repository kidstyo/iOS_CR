//
//  EventItem.swift
//  EventsWidget
//
//  Created by Gregor Hermanowski on 29. March 2022.
//

import EventKit
import SwiftUI

struct EventItem: View {
    internal init(_ event: EKEvent) {
        self.event = event
    }

    @Environment(\.colorScheme) private var colourScheme

    private let event: EKEvent

    var body: some View {
        let eventColour = Color(cgColor: event.calendar.cgColor)

        HStack {
            VStack(alignment: .leading) {
                // Title
                Text(event.title)
                    .font(.footnote.weight(.semibold))

                // Date Range
                if !event.isAllDay {
                    Text(event.startDate...event.endDate)
                        .font(.caption)
                }
                
                if let notes = event.notes, !notes.isEmpty{
                    Text(notes)
                        .font(.caption)
                }
                
                if let location = event.location, !location.isEmpty{
                    Text(location)
                        .font(.caption)
                }

                DisclosureGroup {
                    Text(event.eventIdentifier)
                        .font(.caption)

                    Text("status:\(event.status.rawValue)")
                        .font(.caption)

                    Text(event.description)
                        .font(.caption)
                    
                    Text(event.calendarItemIdentifier)
                        .font(.caption)
                    
                    // 似乎不同设备一致
                    Text(event.calendarItemExternalIdentifier)
                        .font(.caption)
                } label: {
                    Text(event.calendarItemExternalIdentifier)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 2)

            Spacer(minLength: .zero)
        }
        .foregroundStyle(eventColour)
        .blendMode(colourScheme == .light ? .plusDarker : .plusLighter)
        .background(eventColour.opacity(0.125), in: .containerRelative)
        .padding(.leading, 7)
        .overlay(alignment: .leading) {
            HStack(spacing: 3) {
                eventColour
                    .frame(maxWidth: 4)
                    .clipShape(.capsule)

                Spacer()
            }
        }
    }
}

struct EventItem_Previews: PreviewProvider {
    static var previews: some View {
        EventItem(EKEvent())
    }
}
