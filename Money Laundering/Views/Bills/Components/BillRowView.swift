//
//  BillRowView.swift
//  Money Laundering
//

import SwiftUI

struct BillRowView: View {
    let bill: Bill

    private var itemCount: Int { (bill.items ?? []).count }

    var body: some View {
        HStack(spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 4) {
                Text(bill.displayTitle)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(bill.date.formatted(date: .abbreviated, time: .omitted))
                    Text("·")
                    Text("\(itemCount) item\(itemCount == 1 ? "" : "s")")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(CurrencyFormatter.rupiah(bill.grandTotal))
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let data = bill.imageData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(AppTheme.categoryColor.opacity(0.18))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "doc.text")
                        .foregroundStyle(AppTheme.categoryColor)
                }
        }
    }
}
