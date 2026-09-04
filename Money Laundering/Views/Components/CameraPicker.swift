//
//  CameraPicker.swift
//  Money Laundering
//

import SwiftUI
import UIKit

/// Wraps `UIImagePickerController`'s camera so a bill can be photographed directly from the form.
struct CameraPicker: UIViewControllerRepresentable {
    /// Called once with the captured photo, or `nil` if the user cancelled. The caller is
    /// responsible for dismissing — relying on `@Environment(\.dismiss)` here resolves to the
    /// enclosing sheet rather than the cover and tears down the whole form.
    var onFinish: (Data?) -> Void

    static var isAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let onFinish: (Data?) -> Void

        init(onFinish: @escaping (Data?) -> Void) {
            self.onFinish = onFinish
        }

        func imagePickerController(
            _: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = info[.originalImage] as? UIImage
            onFinish(image.flatMap { ReceiptImage.compressedData(from: $0) })
        }

        func imagePickerControllerDidCancel(_: UIImagePickerController) {
            onFinish(nil)
        }
    }
}
