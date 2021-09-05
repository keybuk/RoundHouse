//
//  ModelClassTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/28/21.
//

import XCTest
import CoreData

@testable import RoundHouse

class ModelClassTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    // MARK: classTitle

    /// Check that classTitle combines modelClass and wheelArrangement
    func testClassTitle() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let model = purchase.addModel()
        model.classification = .dieselElectricLocomotive
        model.modelClass = "47/4"
        model.wheelArrangement = "Co-Co"

        XCTAssertEqual(model.classTitle, "47/4 Co-Co")
    }

    /// Check that classTitle returns wheelArrangement when modelClass is empty.
    func testClassTitleWheelArrangementNoClass() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let model = purchase.addModel()
        model.classification = .dieselElectricLocomotive
        model.wheelArrangement = "Co-Co"

        XCTAssertEqual(model.classTitle, "Co-Co")
    }

    /// Check that classTitle works when wheelArrangement is empty.
    func testClassTitleNoWheelArrangement() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let model = purchase.addModel()
        model.classification = .dieselElectricLocomotive
        model.modelClass = "47/4"

        XCTAssertEqual(model.classTitle, "47/4")
    }

    /// Check that classTitle combines modelClass and vehicleType
    func testClassTitleVehicleType() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let model = purchase.addModel()
        model.classification = .multipleUnit
        model.modelClass = "390"
        model.vehicleType = "DMBSO"

        XCTAssertEqual(model.classTitle, "390 DMBSO")
    }

    /// Check that classTitle returns vehicleType when modelClass is empty
    func testClassTitleVehicleTypeNoClass() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let model = purchase.addModel()
        model.classification = .multipleUnit
        model.vehicleType = "DMBSO"

        XCTAssertEqual(model.classTitle, "DMBSO")
    }

    /// Check that classTitle works when vehicleType is empty.
    func testClassTitleNoVehicleType() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let model = purchase.addModel()
        model.classification = .multipleUnit
        model.modelClass = "390"

        XCTAssertEqual(model.classTitle, "390")
    }
}
