//
//  DecoderDateTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import XCTest
import CoreData

@testable import RoundHouse

class DecoderDateTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    /// Check that we can store and retrieve DateComponents via the transformer.
    func testTransformer() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        let decoder = decoderType.addDecoder()
        decoder.firmwareDateComponents = DateComponents(year: 2020, month: 6, day: 13)

        try persistenceController.container.viewContext.save()
        persistenceController.container.viewContext.refreshAllObjects()

        XCTAssertEqual(decoder.firmwareDateComponents, DateComponents(year: 2020, month: 6, day: 13),
                       "firmwareDateComponents did not have expected value after refresh")
    }
}
