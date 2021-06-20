//
//  PurchaseDateTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import XCTest
import CoreData

@testable import RoundHouse

class PurchaseDateTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    /// Check that we can store and retrieve DateComponents via the transformer.
    func testTransformer() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.dateComponents = DateComponents(year: 2020, month: 6, day: 13)

        try persistenceController.container.viewContext.save()
        persistenceController.container.viewContext.refreshAllObjects()

        XCTAssertEqual(purchase.dateComponents, DateComponents(year: 2020, month: 6, day: 13),
                       "dateComponents did not have expected value after refresh")
    }

    /// Check that `dateForSort` is set from `dateComponents`.
    func testDateForSort() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.dateComponents = DateComponents(year: 2020, month: 6, day: 13)

        try persistenceController.container.viewContext.save()

        XCTAssertEqual(purchase.dateForSort, Date(timeIntervalSince1970: 1592006400),
                       "dateForSort did not have expected value")
    }

    /// Check that `dateForSort` is `.distantPast` when `dateComponents` is not set.
    func testDateForSortDistantPast() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        try persistenceController.container.viewContext.save()

        XCTAssertEqual(purchase.dateForSort, .distantPast,
                       "dateForSort did not have expected value")
    }
}
