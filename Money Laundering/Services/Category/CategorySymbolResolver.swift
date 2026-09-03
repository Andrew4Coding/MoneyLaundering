//
//  CategorySymbolResolver.swift
//  Money Laundering
//

import Foundation

/// Picks an SF Symbol for a category from its name and description, so the user never has to
/// choose an icon when creating one.
enum CategorySymbolResolver {
    static let fallbackSymbol = "tag.fill"

    static func symbol(forName name: String, description: String = "", scope: CategoryScope = .both) -> String {
        let haystack = "\(name) \(description)".lowercased()

        for rule in rules where rule.keywords.contains(where: haystack.contains) {
            return rule.symbolName
        }

        switch scope {
        case .income: return "arrow.down.circle.fill"
        case .expense: return "cart.fill"
        case .both: return fallbackSymbol
        }
    }

    private struct Rule {
        let keywords: [String]
        let symbolName: String
    }

    private static let rules: [Rule] = [
        Rule(keywords: ["food", "meal", "eat", "restaurant", "grocer", "makan", "snack", "lunch", "dinner", "breakfast"], symbolName: "fork.knife"),
        Rule(keywords: ["coffee", "cafe", "drink", "kopi", "tea"], symbolName: "cup.and.saucer.fill"),
        Rule(keywords: ["transport", "car", "ride", "fuel", "gas", "taxi", "bus", "train", "commute", "ojek"], symbolName: "car.fill"),
        Rule(keywords: ["flight", "travel", "trip", "holiday", "vacation", "hotel"], symbolName: "airplane"),
        Rule(keywords: ["shop", "clothes", "fashion", "purchase", "belanja", "store"], symbolName: "bag.fill"),
        Rule(keywords: ["bill", "utility", "rent", "electric", "water", "internet", "subscription"], symbolName: "doc.text.fill"),
        Rule(keywords: ["phone", "mobile", "pulsa", "data plan"], symbolName: "iphone"),
        Rule(keywords: ["entertain", "movie", "game", "fun", "music", "concert"], symbolName: "gamecontroller.fill"),
        Rule(keywords: ["health", "medic", "doctor", "hospital", "pharmacy", "obat", "dental"], symbolName: "cross.case.fill"),
        Rule(keywords: ["fitness", "gym", "sport", "workout"], symbolName: "figure.run"),
        Rule(keywords: ["education", "school", "course", "book", "tuition", "study", "kuliah"], symbolName: "book.fill"),
        Rule(keywords: ["pet", "cat", "dog"], symbolName: "pawprint.fill"),
        Rule(keywords: ["home", "house", "furniture", "repair"], symbolName: "house.fill"),
        Rule(keywords: ["salary", "wage", "payroll", "gaji"], symbolName: "banknote.fill"),
        Rule(keywords: ["reimburse", "refund", "claim", "payback"], symbolName: "arrow.uturn.backward.circle.fill"),
        Rule(keywords: ["bonus", "gift", "prize", "reward", "hadiah"], symbolName: "gift.fill"),
        Rule(keywords: ["invest", "stock", "dividend", "saving", "interest"], symbolName: "chart.line.uptrend.xyaxis"),
        Rule(keywords: ["freelance", "side", "project", "business", "client"], symbolName: "briefcase.fill"),
        Rule(keywords: ["donation", "charity", "zakat", "sedekah"], symbolName: "heart.fill"),
        Rule(keywords: ["tax", "fee", "admin", "charge"], symbolName: "percent"),
        Rule(keywords: ["transfer", "topup", "top up", "withdraw"], symbolName: "arrow.left.arrow.right"),
        Rule(keywords: ["other", "misc"], symbolName: "questionmark.circle.fill"),
    ]
}
