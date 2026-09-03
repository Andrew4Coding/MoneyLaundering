//
//  DateRangePickerSheet.swift
//  Money Laundering
//

import SwiftUI

/// Custom start/end date picker, used when the "Custom" period preset is selected.
struct DateRangePickerSheet: View {
    @Binding var range: ClosedRange<Date>?
    @Environment(\.dismiss) private var dismiss

    @State private var start: Date
    @State private var end: Date

    init(range: Binding<ClosedRange<Date>?>) {
        _range = range
        let now = Date.now
        _start = State(initialValue: range.wrappedValue?.lowerBound ?? now)
        _end = State(initialValue: range.wrappedValue?.upperBound ?? now)
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("From", selection: $start, displayedComponents: [.date])
                DatePicker("To", selection: $end, displayedComponents: [.date])
            }
            .navigationTitle("Custom Range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        let calendar = Calendar.current
                        let clampedEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: end))!.addingTimeInterval(-1)
                        range = min(start, end) ... max(clampedEnd, start)
                        dismiss()
                    }
                }
            }
        }
    }
}
