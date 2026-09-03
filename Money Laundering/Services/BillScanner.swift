//
//  BillScanner.swift
//  Money Laundering
//

import Foundation

/// Runs the full bill-scan pipeline: OCR the photo, then parse the text into structured items.
/// The regex heuristic runs first; the on-device model is only tried on the raw OCR text when
/// the heuristic can't identify any items.
enum BillScanner {
    enum Outcome {
        case success(ParsedBill, usedAI: Bool)
        case failure(String)
    }

    static func scan(imageData: Data) async -> Outcome {
        let text: String
        do {
            text = try await BillTextRecognizer.recognize(imageData: imageData)
        } catch {
            return .failure(error.localizedDescription)
        }

        let heuristic = BillHeuristicParser.parse(text: text)
        if !heuristic.items.isEmpty {
            return .success(heuristic, usedAI: false)
        }

        if BillParser.isAvailable {
            if let parsed = try? await BillParser.parse(text: text), !parsed.items.isEmpty {
                return .success(parsed, usedAI: true)
            }
        }

        // Neither could identify items — hand back the heuristic result so any tax/merchant it
        // found is still applied and the user can add the items by hand.
        return .success(heuristic, usedAI: false)
    }
}
