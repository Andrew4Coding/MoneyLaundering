//
//  BillTextRecognizer.swift
//  Money Laundering
//

import Foundation
import ImageIO
import OSLog
import UIKit
import Vision

/// On-device OCR for a bill photo, using the Vision text recognizer.
enum BillTextRecognizer {
    enum RecognizerError: LocalizedError {
        case invalidImage
        case noText

        var errorDescription: String? {
            switch self {
            case .invalidImage: "That image couldn't be read."
            case .noText: "No text was found in the image."
            }
        }
    }

    static func recognize(imageData: Data) async throws -> String {
        guard let uiImage = UIImage(data: imageData), let cgImage = uiImage.cgImage else {
            AppLog.billScan.error("OCR aborted: image data (\(imageData.count) bytes) is not a decodable image")
            throw RecognizerError.invalidImage
        }
        // `cgImage` drops the orientation flag; pass it through so a photo taken in portrait
        // isn't read sideways.
        let orientation = CGImagePropertyOrientation(uiImage.imageOrientation)

        var request = RecognizeTextRequest()
        request.recognitionLevel = .accurate
        let preferred = ["en-US", "id-ID", "ms-MY"].map { Locale.Language(identifier: $0) }
        let supported = request.supportedRecognitionLanguages
        let languages = preferred.filter(supported.contains)
        request.recognitionLanguages = languages.isEmpty ? [Locale.Language(identifier: "en-US")] : languages
        request.usesLanguageCorrection = !languages.isEmpty

        AppLog.billScan.debug(
            "OCR start: \(cgImage.width)x\(cgImage.height), orientation \(orientation.rawValue), languages \(request.recognitionLanguages.map(\.maximalIdentifier).joined(separator: ","))"
        )

        let observations: [RecognizedTextObservation]
        do {
            observations = try await request.perform(on: cgImage, orientation: orientation)
        } catch {
            AppLog.billScan.error("OCR failed — rescan needed: \(error.localizedDescription, privacy: .public)")
            throw error
        }

        let lines = observations.compactMap { $0.topCandidates(1).first?.string }
        let text = lines.joined(separator: "\n")

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            AppLog.billScan.error("OCR found no text in \(observations.count) region(s) — rescan needed")
            throw RecognizerError.noText
        }

        AppLog.billScan.debug("OCR ok: \(lines.count) line(s), \(text.count) char(s)")
        AppLog.billScan.debug("OCR result:\n\(text, privacy: .public)")
        return text
    }
}

private extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
