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
                Self.writeToInbox(compressed, log: self.log)
            } else {
                self.log.error("Could not load the shared image")
            }
            DispatchQueue.main.async { self.openHostApp() }
        }
    }

    private nonisolated func loadImage(from provider: NSItemProvider, completion: @escaping (UIImage?) -> Void) {
        let imageTypes = provider.registeredTypeIdentifiers.filter {
            UTType($0)?.conforms(to: .image) == true
        }
        loadData(from: provider, types: imageTypes.isEmpty ? [UTType.image.identifier] : imageTypes, completion: completion)
    }

    /// Tries `loadDataRepresentation` for each candidate UTType, then falls back to the object loader.
    private nonisolated func loadData(
        from provider: NSItemProvider,
        types: [String],
        completion: @escaping (UIImage?) -> Void
    ) {
        guard let typeID = types.first else {
            loadObject(from: provider, completion: completion)
            return
        }
        provider.loadDataRepresentation(forTypeIdentifier: typeID) { [self] data, error in
            if let error {
                log.error("loadDataRepresentation(\(typeID, privacy: .public)) failed: \(error.localizedDescription, privacy: .public)")
            }
            if let data, let image = UIImage(data: data) {
                completion(image)
            } else {
                loadData(from: provider, types: Array(types.dropFirst()), completion: completion)
            }
        }
    }

    /// Tries `loadObject(ofClass: UIImage.self)`, then the legacy `loadItem` API.
    private nonisolated func loadObject(from provider: NSItemProvider, completion: @escaping (UIImage?) -> Void) {
        guard provider.canLoadObject(ofClass: UIImage.self) else {
            loadItem(from: provider, completion: completion)
            return
        }
        provider.loadObject(ofClass: UIImage.self) { [self] object, error in
            if let error {
                log.error("loadObject(UIImage) failed: \(error.localizedDescription, privacy: .public)")
            }
            if let image = object as? UIImage {
                completion(image)
            } else {
                loadItem(from: provider, completion: completion)
            }
        }
    }

    /// Last-resort loader for providers that only implement the legacy `loadItem` API.
    private nonisolated func loadItem(from provider: NSItemProvider, completion: @escaping (UIImage?) -> Void) {
        let typeID = provider.registeredTypeIdentifiers.first {
            UTType($0)?.conforms(to: .image) == true
        } ?? UTType.image.identifier
        provider.loadItem(forTypeIdentifier: typeID) { [self] item, error in
            if let error {
                log.error("loadItem(\(typeID, privacy: .public)) failed: \(error.localizedDescription, privacy: .public)")
            }
            switch item {
            case let image as UIImage:
                completion(image)
            case let data as Data:
                completion(UIImage(data: data))
            case let url as URL where url.isFileURL:
                let scoped = url.startAccessingSecurityScopedResource()
                defer {
                    if scoped {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                completion((try? Data(contentsOf: url)).flatMap(UIImage.init(data:)))
            default:
                log.error("loadItem returned unsupported type: \(String(describing: item), privacy: .public)")
                completion(nil)
            }
        }
    }

    // MARK: - Output

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
    private static func writeToInbox(_ data: Data, log: Logger) {
        guard let container = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
        else {
            log.error("App Group container \(appGroupID, privacy: .public) is unavailable — check entitlements")
            return
        }
        do {
            try data.write(to: container.appendingPathComponent(receiptFileName), options: .atomic)
        } catch {
            log.error("Writing receipt to inbox failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func openHostApp() {
        openURL(hostAppURL)
        finish()
    }

    ///    https://stackoverflow.com/a/78975759
    @objc
    @discardableResult
    private func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                if #available(iOS 18.0, *) {
                    application.open(url, options: [:], completionHandler: nil)
                    return true
                } else {
                    return application.perform(#selector(openURL(_:)), with: url) != nil
                }
            }
            responder = responder?.next
        }
        return false
    }

    private func finish() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
