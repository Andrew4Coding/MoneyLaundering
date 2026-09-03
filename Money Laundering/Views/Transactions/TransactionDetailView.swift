//
//  TransactionDetailView.swift
//  Money Laundering
//

import SwiftUI
import SwiftData

/// Full detail screen for a single transaction, reachable by tapping a row, with edit and delete.
struct TransactionDetailView: View {
    let transaction: Transaction

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var isPresentingEdit = false
    @State private var isPresentingDeleteConfirm = false
    @State private var isPresentingReceipt = false

    private var amountColor: Color {
        transaction.type == .income ? .green : .red
    }

    private var signedAmountText: String {
        let prefix = transaction.type == .income ? "+" : "-"
        return "\(prefix)\(CurrencyFormatter.rupiah(transaction.amount))"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    CategoryBadgeView(category: transaction.category, size: 64)
                    Text(transaction.title)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                    Text(signedAmountText)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(amountColor)
                        .monospacedDigit()
                }
                .padding(.top, 12)

                VStack(spacing: 0) {
                    detailRow(label: "Type", value: transaction.type.displayName)
                    Divider().padding(.leading, 16)
                    detailRow(label: "Category", value: transaction.category?.name ?? "Uncategorized")
                    Divider().padding(.leading, 16)
                    detailRow(label: "Source", value: transaction.source.displayName)
                    Divider().padding(.leading, 16)
                    detailRow(label: "Date", value: transaction.date.formatted(date: .long, time: .omitted))
                    if transaction.receiptImageData != nil {
                        Divider().padding(.leading, 16)
                        receiptRow
                    }
                    if !transaction.transactionDescription.isEmpty {
                        Divider().padding(.leading, 16)
                        detailRow(label: "Description", value: transaction.transactionDescription)
                    }
                }
                .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        isPresentingEdit = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        isPresentingDeleteConfirm = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .fullScreenCover(isPresented: $isPresentingReceipt) {
            if let data = transaction.receiptImageData {
                ReceiptViewer(imageData: data) { isPresentingReceipt = false }
            }
        }
        .sheet(isPresented: $isPresentingEdit) {
            AddTransactionView(transaction: transaction)
        }
        .confirmationDialog(
            "Delete this transaction? This cannot be undone.",
            isPresented: $isPresentingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                modelContext.delete(transaction)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var receiptRow: some View {
        Button {
            isPresentingReceipt = true
        } label: {
            HStack {
                Text("Bill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                if let data = transaction.receiptImageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .multilineTextAlignment(.trailing)
        }
        .padding(16)
    }
}

#Preview {
    let category = TransactionCategory(name: "Food", iconType: .system, iconValue: "fork.knife", isDefault: true)
    NavigationStack {
        TransactionDetailView(
            transaction: Transaction(type: .expense, title: "Lunch", amount: 45000, source: .grab, date: .now, description: "Padang food with friends", category: category)
        )
    }
}
