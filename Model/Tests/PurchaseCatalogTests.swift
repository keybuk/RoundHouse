//
//  PurchaseCatalogTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 7/6/21.
//

import XCTest
import CoreData

@testable import RoundHouse

class PurchaseCatalogTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    // MARK: catalogNumberPrefix

    /// Check that the catalogNumberPrefix field is set on save.
    func testCatalogNumberPrefix() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.catalogNumber = "R3745A"

        try persistenceController.container.viewContext.save()

        XCTAssertEqual(purchase.catalogNumberPrefix, "R3745",
                       "catalogNumberPrefix did not have expected value")
    }

    /// Check catalogNumberPrefix contains empty string when `catalogNumber` is not set.
    func testNilCatalogNumberPrefix() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        try persistenceController.container.viewContext.save()

        XCTAssertEqual(purchase.catalogNumberPrefix, "",
                       "catalogNumberPrefix did not have expected value")
    }

    // MARK: catalogTitle

    /// Check that catalogTitle combines manufacturer and catalogNumber
    func testCatalogTitle() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R3745A"

        XCTAssertEqual(purchase.catalogTitle, "Hornby R3745A")
    }

    /// Check that catalogTitle works when manufacturer is empty.
    func testCatalogTitleNoManufacturer() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.catalogNumber = "R3745A"

        XCTAssertEqual(purchase.catalogTitle, "R3745A")
    }

    /// Check that catalogTitle works when catalogNumber is empty.
    func testCatalogTitleNoNumber() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.manufacturer = "Hornby"

        XCTAssertEqual(purchase.catalogTitle, "Hornby")
    }
}
