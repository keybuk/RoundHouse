//
//  ModelDateTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import XCTest
import CoreData

@testable import RoundHouse

class ModelDateTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    func testTransformer() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let model = purchase.addModel()
        model.lastRunDateComponents = DateComponents(year: 2020, month: 6, day: 13)
        model.lastOilDateComponents = DateComponents(year: 2021, month: 1, day: 17)

        try persistenceController.container.viewContext.save()
        persistenceController.container.viewContext.refreshAllObjects()

        XCTAssertEqual(model.lastRunDateComponents, DateComponents(year: 2020, month: 6, day: 13),
                       "lastRunDateComponents did not have expected value after refresh")
        XCTAssertEqual(model.lastOilDateComponents, DateComponents(year: 2021, month: 1, day: 17),
                       "lastOilDateComponents did not have expected value after refresh")
    }
}
