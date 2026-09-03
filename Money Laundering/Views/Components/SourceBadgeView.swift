//
//  SourceBadgeView.swift
//  Money Laundering
//

import SwiftUI

/// Small secondary badge showing which money source a transaction used. Sources without a logo
/// in the asset catalog fall back to an SF Symbol plus their name.
struct SourceBadgeView: View {
    let source: MoneySource

    var body: some View {
        HStack(spacing: 4) {
            if let imageName = source.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 12)
            } else {
                Image(systemName: source.symbolName)
                    .font(.system(size: 9, weight: .semibold))
                Text(source.displayName)
                    .font(.system(size: 9, weight: .semibold))
            }
        }
        .foregroundStyle(Color(hex: source.colorHex))
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
