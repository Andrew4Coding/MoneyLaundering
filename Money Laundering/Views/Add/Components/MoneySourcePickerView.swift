//
//  MoneySourcePickerView.swift
//  Money Laundering
//

import SwiftUI

struct MoneySourcePickerView: View {
    @Binding var selection: MoneySource
    var transactionType: TransactionType = .expense

    private var sources: [MoneySource] {
        MoneySource.available(for: transactionType)
    }

    var body: some View {
        Picker("Source", selection: $selection) {
            ForEach(sources) { source in
                Text(source.displayName).tag(source)
            }
        }
    }
}

#Preview {
    @Previewable @State var source: MoneySource = .bca
    Form {
        MoneySourcePickerView(selection: $source, transactionType: .income)
    }
}
