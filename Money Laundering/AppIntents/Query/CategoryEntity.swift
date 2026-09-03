//
//  CategoryEntity.swift
//  Money Laundering
//

import AppIntents
import SwiftData

/// App Intents view of a `TransactionCategory`, so the "Category" parameter shows a picker of
/// the user's real categories instead of a free-text field. Identified by name (categories are
/// de-duped by name across the app).
struct CategoryEntity: AppEntity {
    var id: String
    var name: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Category" }

    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "\(name)") }

    static var defaultQuery = CategoryEntityQuery()
}

struct CategoryEntityQuery: EntityQuery {
    @MainActor
    func entities(for identifiers: [String]) async throws -> [CategoryEntity] {
        try all().filter { identifiers.contains($0.id) }
    }

    @MainActor
    func suggestedEntities() async throws -> [CategoryEntity] {
        try all()
    }

    @MainActor
    func all() throws -> [CategoryEntity] {
        let context = Persistance.container.mainContext
        let descriptor = FetchDescriptor<TransactionCategory>(sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor).map { CategoryEntity(id: $0.name, name: $0.name) }
    }
}
