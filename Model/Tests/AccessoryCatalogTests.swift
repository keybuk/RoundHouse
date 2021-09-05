//
//  AccessoryCatalogTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/28/21.
//

import XCTest
import CoreData

@testable import RoundHouse

class AccessoryCatalogTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    // MARK: catalogTitle

    /// Check that catalogTitle combines manufacturer and catalogNumber
    func testCatalogTitle() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let accessory = purchase.addAccessory()
        accessory.manufacturer = "Hornby"
        accessory.catalogNumber = "R600"

        XCTAssertEqual(accessory.catalogTitle, "Hornby R600")
    }

    /// Check that catalogTitle works when manufacturer is empty.
    func testCatalogTitleNoManufacturer() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let accessory = purchase.addAccessory()
        accessory.catalogNumber = "R600"

        XCTAssertEqual(accessory.catalogTitle, "R600")
    }

    /// Check that catalogTitle works when catalogNumber is empty.
    func testCatalogTitleNoNumber() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let accessory = purchase.addAccessory()
        accessory.manufacturer = "Hornby"

        XCTAssertEqual(accessory.catalogTitle, "Hornby")
    }
}
