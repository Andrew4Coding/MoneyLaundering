//
//  MoneySourcePickerView.swift
//  Money Laundering
//

import SwiftUI

struct MoneySourcePickerView: View {
    @Binding var selection: MoneySource

    var body: some View {
        Picker("Source", selection: $selection) {
            ForEach(MoneySource.allCases) { source in
                Text(source.displayName)
                .tag(
                    source
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var source: MoneySource = .bca
    Form {
        MoneySourcePickerView(selection: $source)
    }
}
