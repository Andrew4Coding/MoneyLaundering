//
//  BillDetailView.swift
//  Money Laundering
//

import SwiftData
import SwiftUI

/// Full detail for a bill: the photo, its items with tick boxes, and the user's computed share.
struct BillDetailView: View {
    @Bindable var bill: Bill

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var isPresentingEdit = false
    @State private var isPresentingImage = false
    @State private var isPresentingDeleteConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let data = bill.imageData, let image = UIImage(data: data) {
                    Button {
                        isPresentingImage = true
                    } label: {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }

                VStack(spacing: 4) {
                    Text(bill.displayTitle)
                        .font(.title3.weight(.semibold))
                    Text(bill.date.formatted(date: .long, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if bill.scanStatus == .failed {
                    Label("Scanning didn't work — items were entered by hand.", systemImage: "exclamationmark.triangle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                itemsSection

                if bill.taxAmount > 0 || bill.serviceAmount > 0 || bill.discountAmount > 0 {
                    chargesSection
                }

                BillSummaryCard(totals: bill.totals)
            }
            .padding()
        }
        .navigationTitle("Bill")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button { isPresentingEdit = true } label: { Label("Edit", systemImage: "pencil") }
                    Button(role: .destructive) { isPresentingDeleteConfirm = true } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $isPresentingEdit) {
            BillEditorView(bill: bill)
        }
        .fullScreenCover(isPresented: $isPresentingImage) {
            if let data = bill.imageData {
                ReceiptViewer(imageData: data) { isPresentingImage = false }
            }
        }
        .confirmationDialog(
            "Delete this bill? This cannot be undone.",
            isPresented: $isPresentingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                modelContext.delete(bill)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var itemsSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Items")
                    .font(.headline)
                Spacer()
                Button(allSelected ? "Deselect All" : "Select All") {
                    let target = !allSelected
                    for item in bill.sortedItems { item.isSelected = target }
                    try? modelContext.save()
                }
                .font(.subheadline)
            }
            .padding(.bottom, 8)

            ForEach(bill.sortedItems) { item in
                Button {
                    item.isSelected.toggle()
                    try? modelContext.save()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(item.isSelected ? AppTheme.accent : .secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name.isEmpty ? "Item" : item.name)
                                .foregroundStyle(.primary)
                            if item.quantity > 1 {
                                Text("×\(item.quantity)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Text(CurrencyFormatter.rupiah(item.lineTotal))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if item.id != bill.sortedItems.last?.id {
                    Divider()
                }
            }

            if bill.sortedItems.isEmpty {
                Text("No items on this bill.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
    }

    private var chargesSection: some View {
        VStack(spacing: 8) {
            chargeLine("Subtotal", bill.itemsSubtotal)
            if bill.taxAmount > 0 { chargeLine("Tax", bill.taxAmount) }
            if bill.serviceAmount > 0 { chargeLine("Service", bill.serviceAmount) }
            if bill.discountAmount > 0 { chargeLine("Discount", -bill.discountAmount) }
            Divider()
            HStack {
                Text("Bill total").font(.subheadline.weight(.semibold))
                Spacer()
                Text(CurrencyFormatter.rupiah(bill.grandTotal))
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
            }
        }
        .padding(16)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func chargeLine(_ label: String, _ amount: Decimal) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(CurrencyFormatter.rupiah(amount)).font(.subheadline).monospacedDigit()
        }
    }

    private var allSelected: Bool {
        let items = bill.sortedItems
        return !items.isEmpty && items.allSatisfy(\.isSelected)
    }
}
