//
//  ModelTitleTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/28/21.
//

import XCTest
import CoreData

@testable import RoundHouse

class ModelTitleTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    /// Check that title combines modelClass and wheelArrangement
    func testTitle() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let model = purchase.addModel()
        model.classification = .dieselElectricLocomotive
        model.modelClass = "47/4"
        model.wheelArrangement = "Co-Co"

        XCTAssertEqual(model.title, "47/4 Co-Co")
    }

    /// Check that title returns wheelArrangement when modelClass is empty.
    func testTitleWheelArrangementNoClass() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let model = purchase.addModel()
        model.classification = .dieselElectricLocomotive
        model.wheelArrangement = "Co-Co"

        XCTAssertEqual(model.title, "Co-Co")
    }

    /// Check that title works when wheelArrangement is empty.
    func testTitleNoWheelArrangement() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let model = purchase.addModel()
        model.classification = .dieselElectricLocomotive
        model.modelClass = "47/4"

        XCTAssertEqual(model.title, "47/4")
    }

    /// Check that title combines modelClass and vehicleType
    func testTitleVehicleType() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let model = purchase.addModel()
        model.classification = .multipleUnit
        model.modelClass = "390"
        model.vehicleType = "DMBSO"

        XCTAssertEqual(model.title, "390 DMBSO")
    }

    /// Check that title returns vehicleType when modelClass is empty
    func testTitleVehicleTypeNoClass() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let model = purchase.addModel()
        model.classification = .multipleUnit
        model.vehicleType = "DMBSO"

        XCTAssertEqual(model.title, "DMBSO")
    }

    /// Check that title works when vehicleType is empty.
    func testTitleNoVehicleType() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let model = purchase.addModel()
        model.classification = .multipleUnit
        model.modelClass = "390"

        XCTAssertEqual(model.title, "390")
    }
}
