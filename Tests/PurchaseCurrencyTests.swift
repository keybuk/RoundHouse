//
//  PurchaseCurrencyTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import XCTest
import CoreData

@testable import RoundHouse

class PurchaseCurrencyTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    func testTypeConversion() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.price = Decimal(299.99)
        purchase.valuation = Decimal(150)

        try persistenceController.container.viewContext.save()
        persistenceController.container.viewContext.refreshAllObjects()

        XCTAssertEqual(purchase.price, Decimal(299.99),
                       "price did not have expected value after refresh")
        XCTAssertEqual(purchase.valuation, Decimal(150),
                       "valuation did not have expected value after refresh")
    }
}
