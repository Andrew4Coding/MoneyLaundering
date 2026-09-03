//
//  ReceiptViewer.swift
//  Money Laundering
//

import SwiftUI

/// Full-screen, zoomable view of an attached bill photo.
struct ReceiptViewer: View {
    let imageData: Data
    let onDone: () -> Void

    @State private var scale: CGFloat = 1

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .gesture(
                            MagnifyGesture()
                                .onChanged { scale = max(1, min(5, $0.magnification)) }
                                .onEnded { _ in
                                    if scale < 1.05 { withAnimation { scale = 1 } }
                                }
                        )
                } else {
                    ContentUnavailableView("Can't Show Bill", systemImage: "photo.badge.exclamationmark")
                }
            }
            .navigationTitle("Bill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDone)
                }
            }
        }
    }
}
