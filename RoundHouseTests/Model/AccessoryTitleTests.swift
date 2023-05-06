//
//  AccessoryTitleTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/28/21.
//

import XCTest
import CoreData

@testable import RoundHouse

class AccessoryTitleTests: XCTestCase {
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
        let accessory = purchase.addAccessory()
        accessory.manufacturer = "Hornby"
        accessory.catalogNumber = "R600"

        XCTAssertEqual(accessory.title, "Hornby R600")
    }

    /// Check that title works when manufacturer is empty.
    func testTitleNoManufacturer() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let accessory = purchase.addAccessory()
        accessory.catalogNumber = "R600"

        XCTAssertEqual(accessory.title, "R600")
    }

    /// Check that title works when catalogNumber is empty.
    func testTitleNoNumber() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let accessory = purchase.addAccessory()
        accessory.manufacturer = "Hornby"

        XCTAssertEqual(accessory.title, "Hornby")
    }
}
