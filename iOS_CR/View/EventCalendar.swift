//
//  EventCalendar.swift
//  iOS_CR
//
//  Created by kidstyo on 2024/5/8.
//

import SwiftUI
import EventKit

struct EventCalendar: View {
    var ca: EKCalendar
    
    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 5, content: {
                Text(ca.title)
                    .font(.footnote)
                    .foregroundColor(Color(cgColor: ca.cgColor))

                Text(ca.description)
                Text("type: \(ca.type.rawValue)")
                Text(ca.calendarIdentifier)
                    .font(.caption2)
            })
            .font(.caption)
            .foregroundColor(.secondary)
        } icon: {
            Image(systemName: "circle.fill")
                .font(.caption2)
                .foregroundColor(Color(cgColor: ca.cgColor))
        }
    }
}
