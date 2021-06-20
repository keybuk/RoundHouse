//
//  PurchaseModelsTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 2/1/20.
//

import XCTest
import CoreData

@testable import RoundHouse

class PurchaseModelsTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    // MARK: addModel

    /// Check that we can add a model to an empty purchase.
    func testAddFirstModel() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let model = purchase.addModel()

        XCTAssertEqual(model.purchase, purchase)
        XCTAssertNotNil(purchase.models)
        XCTAssertTrue(purchase.models?.contains(model) ?? false)

        XCTAssertEqual(model.index, 0)
    }

    /// Check that we can add a second model to a purchase.
    func testAddSecondModel() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var models: [Model] = []
        for index in 0...0 {
            let model = Model(context: persistenceController.container.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
            purchase.maxModelIndex = model.index
        }

        let model = purchase.addModel()

        XCTAssertEqual(model.purchase, purchase)
        XCTAssertNotNil(purchase.models)
        XCTAssertTrue(purchase.models?.contains(model) ?? false)

        XCTAssertEqual(model.index, 1)

        XCTAssertEqual(models[0].index, 0)
    }

    /// Check that adding a model makes minimal changes to indexes.
    func testAddMinimizesChanges() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var models: [Model] = []
        for index in 0...0 {
            let model = Model(context: persistenceController.container.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
            purchase.maxModelIndex = model.index
        }

        try persistenceController.container.viewContext.save()

        let _ = purchase.addModel()

        XCTAssertFalse(models[0].hasChanges)
    }

    // MARK: removeModel

    /// Check that we can remove the only model from a purchase.
    func testRemoveModel() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var models: [Model] = []
        for index in 0...0 {
            let model = Model(context: persistenceController.container.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
            purchase.maxModelIndex = model.index
        }

        purchase.removeModel(models[0])

        XCTAssertTrue(models[0].isDeleted)
        XCTAssertNil(models[0].purchase)
        XCTAssertFalse(purchase.models?.contains(models[0]) ?? false)
    }

    /// Check that we can remove a second model from a purchase.
    func testRemoveSecondModel() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var models: [Model] = []
        for index in 0...1 {
            let model = Model(context: persistenceController.container.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
            purchase.maxModelIndex = model.index
        }

        purchase.removeModel(models[1])

        XCTAssertTrue(models[1].isDeleted)
        XCTAssertNil(models[1].purchase)
        XCTAssertFalse(purchase.models?.contains(models[1]) ?? false)
        XCTAssertTrue(purchase.models?.contains(models[0]) ?? false)

        XCTAssertEqual(models[0].index, 0)
    }

    /// Check that we can remove the first of two models from a purchase, and the second is reindexed.
    func testRemoveFirstModelOfTwo() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var models: [Model] = []
        for index in 0...1 {
            let model = Model(context: persistenceController.container.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
            purchase.maxModelIndex = model.index
        }

        purchase.removeModel(models[0])

        XCTAssertTrue(models[0].isDeleted)
        XCTAssertNil(models[0].purchase)
        XCTAssertFalse(purchase.models?.contains(models[0]) ?? false)
        XCTAssertTrue(purchase.models?.contains(models[1]) ?? false)

        XCTAssertEqual(models[1].index, 0)
    }

    /// Check that we can remove the first of three models from a purchase, and the second and third are reindexed.
    func testRemoveFirstModelOfThree() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var models: [Model] = []
        for index in 0...2 {
            let model = Model(context: persistenceController.container.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
            purchase.maxModelIndex = model.index
        }

        purchase.removeModel(models[0])

        XCTAssertTrue(models[0].isDeleted)
        XCTAssertNil(models[0].purchase)
        XCTAssertFalse(purchase.models?.contains(models[0]) ?? false)
        XCTAssertTrue(purchase.models?.contains(models[1]) ?? false)
        XCTAssertTrue(purchase.models?.contains(models[2]) ?? false)

        XCTAssertEqual(models[1].index, 0)
        XCTAssertEqual(models[2].index, 1)
    }

    /// Check that removing a model makes minimal changes to indxes.
    func testRemoveMinimxesChanges() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var models: [Model] = []
        for index in 0...1 {
            let model = Model(context: persistenceController.container.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
            purchase.maxModelIndex = model.index
        }

        try persistenceController.container.viewContext.save()

        purchase.removeModel(models[1])

        XCTAssertFalse(models[0].hasChanges)
    }

    // MARK: moveModel

    /// Check that moving a model forwards works.
    func testMoveModelForwards() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var models: [Model] = []
        for index in 0...5 {
            let model = Model(context: persistenceController.container.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
            purchase.maxModelIndex = model.index
        }

        purchase.moveModelAt(4, to: 2)

        XCTAssertEqual(models[0].index, 0)
        XCTAssertEqual(models[1].index, 1)
        XCTAssertEqual(models[2].index, 3)
        XCTAssertEqual(models[3].index, 4)
        XCTAssertEqual(models[4].index, 2)
        XCTAssertEqual(models[5].index, 5)
    }

    /// Check that moving a model backwards works.
    func testMoveModelBackwards() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var models: [Model] = []
        for index in 0...5 {
            let model = Model(context: persistenceController.container.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
            purchase.maxModelIndex = model.index
        }

        purchase.moveModelAt(1, to: 3)

        XCTAssertEqual(models[0].index, 0)
        XCTAssertEqual(models[1].index, 3)
        XCTAssertEqual(models[2].index, 1)
        XCTAssertEqual(models[3].index, 2)
        XCTAssertEqual(models[4].index, 4)
        XCTAssertEqual(models[5].index, 5)
    }

    /// Check that moving a model to its existing location does nothing.
    func testMoveModelToSameModel() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var models: [Model] = []
        for index in 0...5 {
            let model = Model(context: persistenceController.container.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
            purchase.maxModelIndex = model.index
        }

        purchase.moveModelAt(4, to: 4)

        for (index, model) in models.enumerated() {
            XCTAssertEqual(model.index, Int16(clamping: index))
        }
    }

    /// Check that swapping two models forward in the middle of the set works.
    func testMoveModelSwapForwards() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var models: [Model] = []
        for index in 0...5 {
            let model = Model(context: persistenceController.container.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
            purchase.maxModelIndex = model.index
        }

        purchase.moveModelAt(2, to: 3)

        XCTAssertEqual(models[0].index, 0)
        XCTAssertEqual(models[1].index, 1)
        XCTAssertEqual(models[2].index, 3)
        XCTAssertEqual(models[3].index, 2)
        XCTAssertEqual(models[4].index, 4)
        XCTAssertEqual(models[5].index, 5)
    }

    /// Check that swapping two models backward in the middle of the set works.
    func testMoveModelSwapBackwards() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var models: [Model] = []
        for index in 0...5 {
            let model = Model(context: persistenceController.container.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
            purchase.maxModelIndex = model.index
        }

        purchase.moveModelAt(3, to: 2)

        XCTAssertEqual(models[0].index, 0)
        XCTAssertEqual(models[1].index, 1)
        XCTAssertEqual(models[2].index, 3)
        XCTAssertEqual(models[3].index, 2)
        XCTAssertEqual(models[4].index, 4)
        XCTAssertEqual(models[5].index, 5)
    }

    /// Check that we can swap two models forward.
    func testMoveModelSwapTwoForwards() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var models: [Model] = []
        for index in 0...1 {
            let model = Model(context: persistenceController.container.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
            purchase.maxModelIndex = model.index
        }

        purchase.moveModelAt(1, to: 0)

        XCTAssertEqual(models[0].index, 1)
        XCTAssertEqual(models[1].index, 0)
    }

    /// Check that we can swap two models backward.
    func testMoveModelSwapTwoBackwards() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var models: [Model] = []
        for index in 0...1 {
            let model = Model(context: persistenceController.container.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
            purchase.maxModelIndex = model.index
        }

        purchase.moveModelAt(0, to: 1)

        XCTAssertEqual(models[0].index, 1)
        XCTAssertEqual(models[1].index, 0)
    }

    /// Check that moving a model makes minimal changes to indexes.
    func testMoveMinimizesChanges() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var models: [Model] = []
        for index in 0...5 {
            let model = Model(context: persistenceController.container.viewContext)
            model.index = Int16(clamping: index)
            purchase.addToModels(model)
            models.append(model)
            purchase.maxModelIndex = model.index
        }

        try persistenceController.container.viewContext.save()

        purchase.moveModelAt(1, to: 3)

        XCTAssertFalse(models[0].hasChanges)
        XCTAssertFalse(models[4].hasChanges)
    }
}
