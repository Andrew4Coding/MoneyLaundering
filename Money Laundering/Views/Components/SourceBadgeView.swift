//
//  SourceBadgeView.swift
//  Money Laundering
//

import SwiftUI

/// Small secondary badge showing which money source (Grab/GoPay/BCA/BNI) a transaction used.
struct SourceBadgeView: View {
    let source: MoneySource

    var body: some View {
        HStack(spacing: 4) {
            Image(source.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 12)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Color(hex: source.colorHex).opacity(0.14), in: Capsule())
        .accessibilityLabel(source.displayName)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        ForEach(MoneySource.allCases) { source in
            SourceBadgeView(source: source)
        }
    }
    .padding()
}
