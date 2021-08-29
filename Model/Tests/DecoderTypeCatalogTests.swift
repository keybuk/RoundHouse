//
//  DecoderTypeCatalogTests.swift
//  DecoderTypeCatalogTests
//
//  Created by Scott James Remnant on 8/28/21.
//

import XCTest
import CoreData

@testable import RoundHouse

class DecoderTypeCatalogTests: XCTestCase {
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
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.manufacturer = "ESU"
        decoderType.catalogNumber = "58429"

        XCTAssertEqual(decoderType.catalogTitle, "ESU 58429")
    }

    /// Check that catalogTitle works when manufacturer is empty.
    func testCatalogTitleNoManufacturer() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.catalogNumber = "58429"

        XCTAssertEqual(decoderType.catalogTitle, "58429")
    }

    /// Check that catalogTitle works when catalogNumber is empty.
    func testCatalogTitleNoNumber() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.manufacturer = "ESU"

        XCTAssertEqual(decoderType.catalogTitle, "ESU")
    }

    // MARK: catalogFamilyTitle

    /// Check that catalogFamilyTitle combines manufacturer and catalogNumber
    func testCatalogFamilyTitle() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.manufacturer = "ESU"
        decoderType.catalogFamily = "LokSound 5"

        XCTAssertEqual(decoderType.catalogFamilyTitle, "ESU LokSound 5")
    }

    /// Check that catalogFamilyTitle works when manufacturer is empty.
    func testCatalogFamilyTitleNoManufacturer() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.catalogFamily = "LokSound 5"

        XCTAssertEqual(decoderType.catalogFamilyTitle, "LokSound 5")
    }

    /// Check that catalogFamilyTitle works when catalogFamily is empty.
    func testCatalogFamilyTitleNoNumber() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.manufacturer = "ESU"

        XCTAssertEqual(decoderType.catalogFamilyTitle, "ESU")
    }
}
