//
//  DecoderTypeTitleTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/28/21.
//

import XCTest
import CoreData

@testable import RoundHouse

class DecoderTypeTitleTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    // MARK: title

    /// Check that title combines manufacturer and catalogNumber
    func testTitle() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.manufacturer = "ESU"
        decoderType.catalogNumber = "58429"

        XCTAssertEqual(decoderType.title, "ESU 58429")
    }

    /// Check that title works when manufacturer is empty.
    func testTitleNoManufacturer() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.catalogNumber = "58429"

        XCTAssertEqual(decoderType.title, "58429")
    }

    /// Check that title works when catalogNumber is empty.
    func testTitleNoNumber() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.manufacturer = "ESU"

        XCTAssertEqual(decoderType.title, "ESU")
    }

    // MARK: family

    /// Check that family combines manufacturer and catalogNumber
    func testFamily() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.manufacturer = "ESU"
        decoderType.catalogFamily = "LokSound 5"

        XCTAssertEqual(decoderType.family, "ESU LokSound 5")
    }

    /// Check that family works when manufacturer is empty.
    func testFamilyNoManufacturer() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.catalogFamily = "LokSound 5"

        XCTAssertEqual(decoderType.family, "LokSound 5")
    }

    /// Check that family works when catalogFamily is empty.
    func testFamilyNoNumber() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.manufacturer = "ESU"

        XCTAssertEqual(decoderType.family, "ESU")
    }

}
