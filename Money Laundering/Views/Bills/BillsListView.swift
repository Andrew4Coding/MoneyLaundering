//
//  BillsListView.swift
//  Money Laundering
//

import SwiftData
import SwiftUI

struct BillsListView: View {
    @Query(sort: \Bill.date, order: .reverse) private var bills: [Bill]
    @Environment(\.modelContext) private var modelContext

    @State private var editingBill: Bill?

    var body: some View {
        NavigationStack {
            List {
                ForEach(bills) { bill in
                    NavigationLink {
                        BillDetailView(bill: bill)
                    } label: {
                        BillRowView(bill: bill)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            editingBill = bill
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
                .onDelete(perform: delete)
            }
            .listStyle(.plain)
            .overlay {
                if bills.isEmpty {
                    EmptyStateView(
                        systemImage: "doc.text.viewfinder",
                        title: "No Bills",
                        message: "Use the scan button to add your first bill."
                    )
                }
            }
            .navigationTitle("Bills")
            .sheet(item: $editingBill) { bill in
                BillEditorView(bill: bill)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(bills[index])
        }
        try? modelContext.save()
    }
}

#Preview {
    BillsListView()
        .modelContainer(for: [Bill.self, BillItem.self], inMemory: true)
}
