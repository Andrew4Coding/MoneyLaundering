//
//  ShareViewController.swift
//  MoneyLaunderingShareExtension
//

import os
import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
    private static let appGroupID = "group.com.andrew4coding.moneylaundering.sharedData"
    private static let receiptFileName = "shared-receipt.jpg"
    private let hostAppURL = URL(string: "moneylaundering://add-transaction")!
    private let log = Logger(
        subsystem: "com.andrew4coding.moneylaundering.Money-Laundering.MoneyLaunderingShareExtension",
        category: "share"
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        handleSharedImage()
    }

    private func handleSharedImage() {
        guard
            let item = extensionContext?.inputItems.first as? NSExtensionItem,
            let provider = item.attachments?.first(where: {
                $0.hasItemConformingToTypeIdentifier(UTType.image.identifier)
            })
        else {
            log.error("No image attachment on the shared item")
            return finish()
        }

        loadImage(from: provider) { [weak self] image in
            guard let self else { return }
            if let image, let compressed = Self.compressedData(from: image) {
                Self.writeToInbox(compressed)
            } else {
                self.log.error("Could not load the shared image")
            }
            DispatchQueue.main.async { self.openHostApp() }
        }
    }

    private nonisolated func loadImage(from provider: NSItemProvider, completion: @escaping (UIImage?) -> Void) {
        let typeID = UTType.image.identifier

        if provider.hasItemConformingToTypeIdentifier(typeID) {
            provider.loadFileRepresentation(forTypeIdentifier: typeID) { [self] url, error in
                if let error {
                    log.error("loadFileRepresentation failed: \(error.localizedDescription, privacy: .public)")
                }
                if let url,
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    completion(image)
                } else {
                    loadImageObject(from: provider, completion: completion)
                }
            }
        } else {
            loadImageObject(from: provider, completion: completion)
        }
    }

    private nonisolated func loadImageObject(from provider: NSItemProvider, completion: @escaping (UIImage?) -> Void) {
        guard provider.canLoadObject(ofClass: UIImage.self) else {
            completion(nil)
            return
        }
        provider.loadObject(ofClass: UIImage.self) { [self] object, error in
            if let error {
                log.error("loadObject(UIImage) failed: \(error.localizedDescription, privacy: .public)")
            }
            completion(object as? UIImage)
        }
    }

    /// Downscales and JPEG-encodes the shared photo so it stays small enough to sync via CloudKit.
    private static func compressedData(from image: UIImage, maxDimension: CGFloat = 2000) -> Data? {
        let longestSide = max(image.size.width, image.size.height)
        let scale = longestSide > maxDimension ? maxDimension / longestSide : 1
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let normalized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return normalized.jpegData(compressionQuality: 0.8)
    }

    /// Writes the pending receipt image into the shared App Group container for the app to consume.
    private static func writeToInbox(_ data: Data) {
        guard let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent(receiptFileName)
        else { return }
        try? data.write(to: url, options: .atomic)
    }

    private func openHostApp() {
        let opened = openViaResponderChain(hostAppURL)
        log.log("Opening host app: \(opened)")
        finish()
    }

    @discardableResult
    private func openViaResponderChain(_ url: URL) -> Bool {
        let selector = NSSelectorFromString("openURL:options:completionHandler:")
        typealias OpenURLC = @convention(c) (NSObject, Selector, NSURL, NSDictionary, Any?) -> Void

        var responder: UIResponder? = self
        while let current = responder {
            if let application = current as? UIApplication, application.responds(to: selector) {
                let implementation = application.method(for: selector)
                let callable = unsafeBitCast(implementation, to: OpenURLC.self)
                callable(application, selector, url as NSURL, NSDictionary(), nil)
                return true
            }
            responder = current.next
        }
        log.error("Responder chain had no UIApplication — cannot open host app")
        return false
    }

    private func finish() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
