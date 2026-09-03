//
//  BillScanner.swift
//  Money Laundering
//

import Foundation
import OSLog

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
            AppLog.billScan.error("Scan failed at OCR — user should rescan: \(error.localizedDescription, privacy: .public)")
            return .failure(error.localizedDescription)
        }

        let heuristic = BillHeuristicParser.parse(text: text)
        // A single item is usually a mis-parse; let the model try before trusting it.
        if heuristic.items.count >= 2 {
            AppLog.billScan.info("Scan ok via heuristic: \(heuristic.items.count) item(s)")
            return .success(heuristic, usedAI: false)
        }

        if BillParser.isAvailable {
            AppLog.billScan.info("Heuristic found \(heuristic.items.count) item(s); falling back to the on-device model")
            do {
                let parsed = try await BillParser.parse(text: text)
                if !parsed.items.isEmpty {
                    AppLog.billScan.info("Scan ok via model: \(parsed.items.count) item(s)")
                    return .success(parsed, usedAI: true)
                }
                AppLog.billScan.error("Model returned no items — user should check the photo and rescan")
            } catch {
                AppLog.billScan.error("Model parse failed — user should rescan: \(error.localizedDescription, privacy: .public)")
            }
        } else {
            AppLog.billScan.error("Heuristic found no items and Apple Intelligence is unavailable — user should rescan or add items by hand")
        }

        // Neither could identify items — hand back the heuristic result so any tax/merchant it
        // found is still applied and the user can add the items by hand.
        return .success(heuristic, usedAI: false)
    }
}
