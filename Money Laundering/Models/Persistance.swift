//
//  Persistance.swift
//  Money Laundering
//
//  Created by Andrew Devito Aryo on 03/09/26.
//

import Foundation
import SwiftData

enum Persistance {
    static let container: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            TransactionCategory.self,
            Bill.self,
            BillItem.self,
        ])

        let config = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private("iCloud.com.andrew4coding.moneylaundering.Money-Laundering")
        )

        let container = try! ModelContainer(for: schema, configurations: [config])
        CategorySeeder.seedIfNeeded(context: container.mainContext)

        return container
    }()
}
