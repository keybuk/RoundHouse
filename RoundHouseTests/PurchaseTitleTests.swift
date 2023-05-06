//
//  PurchaseTitleTests.swift
//  RoundHouseTests
//
//  Created by Scott James Remnant on 5/5/23.
//

import XCTest
import CoreData

@testable import RoundHouse

final class PurchaseTitleTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    /// Check that title combines manufacturer and catalogNumber
    func testTitle() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.manufacturer = "Hornby"
        purchase.catalogNumber = "R3745A"

        XCTAssertEqual(purchase.title, "Hornby R3745A")
    }

    /// Check that title works when manufacturer is empty.
    func testTitleNoManufacturer() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.catalogNumber = "R3745A"

        XCTAssertEqual(purchase.title, "R3745A")
    }

    /// Check that title works when catalogNumber is empty.
    func testTitleNoNumber() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.manufacturer = "Hornby"

        XCTAssertEqual(purchase.title, "Hornby")
    }
}
