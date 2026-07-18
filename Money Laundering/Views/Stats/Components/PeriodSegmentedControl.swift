//
//  PeriodSegmentedControl.swift
//  Money Laundering
//

import SwiftUI

struct PeriodSegmentedControl: View {
    @Binding var selectedPeriod: StatsPeriod
    @Binding var customRange: ClosedRange<Date>?

    @State private var isPresentingCustomRange = false

    var body: some View {
        Picker("Period", selection: Binding(
            get: { selectedPeriod },
            set: { newValue in
                if newValue == .custom {
                    isPresentingCustomRange = true
                } else {
                    selectedPeriod = newValue
                }
            }
        )) {
            ForEach(StatsPeriod.allCases) { period in
                Text(period.displayName).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .sheet(isPresented: $isPresentingCustomRange) {
            DateRangePickerSheet(range: $customRange)
                .onDisappear {
                    if customRange != nil {
                        selectedPeriod = .custom
                    }
                }
        }
    }
}
