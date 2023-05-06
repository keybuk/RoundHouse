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

    /// Check that we can convert to and from Decimal via the property.
    func testTypeConversion() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.price = Decimal(299.99)
        purchase.valuation = Decimal(150)

        try persistenceController.container.viewContext.save()
        persistenceController.container.viewContext.refreshAllObjects()

        XCTAssertEqual(purchase.price, Decimal(299.99),
                       "price did not have expected value")
        XCTAssertEqual(purchase.valuation, Decimal(150),
                       "valuation did not have expected value")
    }

    /// Check that we can obtain a formatter for currencies via the properties.
    func testFormatStyleConversion() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.price = Decimal(299.99)
        purchase.priceCurrency = "GBP"
        purchase.valuation = Decimal(150)
        purchase.valuationCurrency = "USD"

        try persistenceController.container.viewContext.save()
        persistenceController.container.viewContext.refreshAllObjects()

        let formattedPrice = purchase.price?.formatted(purchase.priceFormatStyle)
        XCTAssertEqual(formattedPrice, "£299.99",
                       "Formatted price did not have expected value")

        let formattedValuation = purchase.valuation?.formatted(purchase.valuationFormatStyle)
        XCTAssertEqual(formattedValuation, "$150.00",
                       "Formatted price did not have expected value")
    }

}
