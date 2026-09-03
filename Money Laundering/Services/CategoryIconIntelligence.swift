//
//  CategoryIconIntelligence.swift
//  Money Laundering
//

import Foundation
import FoundationModels

/// Uses Apple Intelligence's on-device language model to pick the SF Symbol that best fits a
/// category's name and description. Guided generation constrains the model to a curated symbol
/// set, so it can never return an invalid symbol name. Falls back to `CategorySymbolResolver`
/// (keyword matching) whenever the model is unavailable or errors.
enum CategoryIconIntelligence {

    /// The closed set of icons the model is allowed to choose from. `@Generable` turns each
    /// case into an allowed output value for guided generation.
    @Generable
    enum Icon: String, CaseIterable {
        case food, drink, groceries, transport, travel, shopping, bills, phone,
             entertainment, health, fitness, education, pet, home, family,
             salary, refund, gift, investment, savings, work, donation, tax, transfer, other

        var symbolName: String {
            switch self {
            case .food: "fork.knife"
            case .drink: "cup.and.saucer.fill"
            case .groceries: "cart.fill"
            case .transport: "car.fill"
            case .travel: "airplane"
            case .shopping: "bag.fill"
            case .bills: "doc.text.fill"
            case .phone: "iphone"
            case .entertainment: "gamecontroller.fill"
            case .health: "cross.case.fill"
            case .fitness: "figure.run"
            case .education: "book.fill"
            case .pet: "pawprint.fill"
            case .home: "house.fill"
            case .family: "person.2.fill"
            case .salary: "banknote.fill"
            case .refund: "arrow.uturn.backward.circle.fill"
            case .gift: "gift.fill"
            case .investment: "chart.line.uptrend.xyaxis"
            case .savings: "wallet.pass.fill"
            case .work: "briefcase.fill"
            case .donation: "heart.fill"
            case .tax: "percent"
            case .transfer: "arrow.left.arrow.right"
            case .other: "tag.fill"
            }
        }
    }

    /// Whether the on-device model is ready to use right now.
    static var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    /// Best-effort icon suggestion. Always returns a valid SF Symbol name — the keyword
    /// resolver's result when Apple Intelligence can't be used.
    static func suggestSymbol(
        name: String,
        description: String,
        scope: CategoryScope
    ) async -> String {
        let fallback = CategorySymbolResolver.symbol(forName: name, description: description, scope: scope)

        guard SystemLanguageModel.default.availability == .available else { return fallback }

        let session = LanguageModelSession(instructions: """
            You choose the single icon that best represents a personal-finance category, \
            given its name and short description. Consider what the user most likely spends \
            money on or receives money for. Answer with one icon only.
            """)

        let prompt = """
            Category name: \(name)
            Description: \(description.isEmpty ? "(none)" : description)
            Applies to: \(scope.displayName)
            """

        do {
            let response = try await session.respond(to: prompt, generating: Icon.self)
            return response.content.symbolName
        } catch {
            return fallback
        }
    }
}
