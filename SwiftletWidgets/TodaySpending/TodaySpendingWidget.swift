//
//  TodaySpendingWidget.swift
//  SwiftletWidgets
//

import SwiftUI
import WidgetKit

struct TodaySpendingEntry: TimelineEntry {
    let date: Date
    let snapshot: TodaySpendingSnapshot
}

struct TodaySpendingProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodaySpendingEntry {
        TodaySpendingEntry(date: .now, snapshot: .sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodaySpendingEntry) -> Void) {
        let snapshot = context.isPreview ? .sample : TodaySpendingSnapshot.load()
        completion(TodaySpendingEntry(date: .now, snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodaySpendingEntry>) -> Void) {
        let entry = TodaySpendingEntry(date: .now, snapshot: TodaySpendingSnapshot.load())

        let nextMidnight = Calendar.current.nextDate(
            after: .now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) ?? .now.addingTimeInterval(60 * 60)

        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }
}

struct TodaySpendingWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: SwiftletWidgetKind.todaySpending, provider: TodaySpendingProvider()) { entry in
            TodaySpendingWidgetView(entry: entry)
                .containerBackground(.background.secondary, for: .widget)
        }
        .configurationDisplayName("Today's Spending")
        .description("Your expenses by category for today.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

extension TodaySpendingSnapshot {
    static let sample = TodaySpendingSnapshot(
        generatedAt: .now,
        totalExpense: 285_000,
        slices: [
            Slice(name: "Food", amount: 150_000, fraction: 0.53),
            Slice(name: "Transport", amount: 85_000, fraction: 0.30),
            Slice(name: "Coffee", amount: 50_000, fraction: 0.17),
        ]
    )
}
