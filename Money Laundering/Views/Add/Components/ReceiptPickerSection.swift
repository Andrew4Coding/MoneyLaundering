//
//  ReceiptPickerSection.swift
//  Money Laundering
//

import PhotosUI
import SwiftUI

/// Rows for the optional bill photo. Presentation of the camera and the full-screen viewer is
/// owned by the enclosing form — a `.fullScreenCover` attached here would be applied to every
/// row of the section, and the competing presentations tear down the whole sheet.
struct ReceiptPickerSection: View {
    @Binding var imageData: Data?
    @Binding var photoItem: PhotosPickerItem?
    let onTakePhoto: () -> Void
    let onViewReceipt: () -> Void

    var body: some View {
        Section("Bill") {
            if let imageData, let image = UIImage(data: imageData) {
                Button(action: onViewReceipt) {
                    HStack(spacing: 12) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Text("View bill")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button("Remove Bill", role: .destructive) {
                    self.imageData = nil
                    photoItem = nil
                }
            } else {
                if CameraPicker.isAvailable {
                    Button(action: onTakePhoto) {
                        Label("Take Photo", systemImage: "camera")
                    }
                }

                PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                }
            }
        }
    }
}
