//
//  PurchaseAccessoriesTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/13/21.
//

import XCTest
import CoreData

@testable import RoundHouse

class PurchaseAccessoriesTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    // MARK: addAccessory

    /// Check that we can add an accessory to an empty purchase.
    func testAddFirstAccessory() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        let accessory = purchase.addAccessory()

        XCTAssertEqual(accessory.purchase, purchase)
        XCTAssertNotNil(purchase.accessories)
        XCTAssertTrue(purchase.accessories?.contains(accessory) ?? false)

        XCTAssertEqual(accessory.index, 0)
    }

    /// Check that we can add a second accessory to a purchase.
    func testAddSecondAccessory() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var accessories: [Accessory] = []
        for index in 0...0 {
            let accessory = Accessory(context: persistenceController.container.viewContext)
            accessory.index = Int16(clamping: index)
            purchase.addToAccessories(accessory)
            accessories.append(accessory)
            purchase.maxAccessoryIndex = accessory.index
        }

        let accessory = purchase.addAccessory()

        XCTAssertEqual(accessory.purchase, purchase)
        XCTAssertNotNil(purchase.accessories)
        XCTAssertTrue(purchase.accessories?.contains(accessory) ?? false)

        XCTAssertEqual(accessory.index, 1)

        XCTAssertEqual(accessories[0].index, 0)
    }

    /// Check that adding an accessory makes minimal changes to indexes.
    func testAddMinimizesChanges() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var accessories: [Accessory] = []
        for index in 0...0 {
            let accessory = Accessory(context: persistenceController.container.viewContext)
            accessory.index = Int16(clamping: index)
            purchase.addToAccessories(accessory)
            accessories.append(accessory)
            purchase.maxAccessoryIndex = accessory.index
        }

        try persistenceController.container.viewContext.save()

        let _ = purchase.addAccessory()

        XCTAssertFalse(accessories[0].hasChanges)
    }

    // MARK: removeAccessory

    /// Check that we can remove the only accessory from a purchase.
    func testRemoveAccessory() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var accessories: [Accessory] = []
        for index in 0...0 {
            let accessory = Accessory(context: persistenceController.container.viewContext)
            accessory.index = Int16(clamping: index)
            purchase.addToAccessories(accessory)
            accessories.append(accessory)
            purchase.maxAccessoryIndex = accessory.index
        }

        purchase.removeAccessory(accessories[0])

        XCTAssertTrue(accessories[0].isDeleted)
        XCTAssertNil(accessories[0].purchase)
        XCTAssertFalse(purchase.accessories?.contains(accessories[0]) ?? false)
    }

    /// Check that we can remove a second accessory from a purchase.
    func testRemoveSecondAccessory() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var accessories: [Accessory] = []
        for index in 0...1 {
            let accessory = Accessory(context: persistenceController.container.viewContext)
            accessory.index = Int16(clamping: index)
            purchase.addToAccessories(accessory)
            accessories.append(accessory)
            purchase.maxAccessoryIndex = accessory.index
        }

        purchase.removeAccessory(accessories[1])

        XCTAssertTrue(accessories[1].isDeleted)
        XCTAssertNil(accessories[1].purchase)
        XCTAssertFalse(purchase.accessories?.contains(accessories[1]) ?? false)
        XCTAssertTrue(purchase.accessories?.contains(accessories[0]) ?? false)

        XCTAssertEqual(accessories[0].index, 0)
    }

    /// Check that we can remove the first of two accessories from a purchase, and the second is reindexed.
    func testRemoveFirstAccessoryOfTwo() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var accessories: [Accessory] = []
        for index in 0...1 {
            let accessory = Accessory(context: persistenceController.container.viewContext)
            accessory.index = Int16(clamping: index)
            purchase.addToAccessories(accessory)
            accessories.append(accessory)
            purchase.maxAccessoryIndex = accessory.index
        }

        purchase.removeAccessory(accessories[0])

        XCTAssertTrue(accessories[0].isDeleted)
        XCTAssertNil(accessories[0].purchase)
        XCTAssertFalse(purchase.accessories?.contains(accessories[0]) ?? false)
        XCTAssertTrue(purchase.accessories?.contains(accessories[1]) ?? false)

        XCTAssertEqual(accessories[1].index, 0)
    }

    /// Check that we can remove the first of three accessories from a purchase, and the second and third are reindexed.
    func testRemoveFirstAccessoryOfThree() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var accessories: [Accessory] = []
        for index in 0...2 {
            let accessory = Accessory(context: persistenceController.container.viewContext)
            accessory.index = Int16(clamping: index)
            purchase.addToAccessories(accessory)
            accessories.append(accessory)
            purchase.maxAccessoryIndex = accessory.index
        }

        purchase.removeAccessory(accessories[0])

        XCTAssertTrue(accessories[0].isDeleted)
        XCTAssertNil(accessories[0].purchase)
        XCTAssertFalse(purchase.accessories?.contains(accessories[0]) ?? false)
        XCTAssertTrue(purchase.accessories?.contains(accessories[1]) ?? false)
        XCTAssertTrue(purchase.accessories?.contains(accessories[2]) ?? false)

        XCTAssertEqual(accessories[1].index, 0)
        XCTAssertEqual(accessories[2].index, 1)
    }

    /// Check that removing an accessory makes minimal changes to indxes.
    func testRemoveMinimxesChanges() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var accessories: [Accessory] = []
        for index in 0...1 {
            let accessory = Accessory(context: persistenceController.container.viewContext)
            accessory.index = Int16(clamping: index)
            purchase.addToAccessories(accessory)
            accessories.append(accessory)
            purchase.maxAccessoryIndex = accessory.index
        }

        try persistenceController.container.viewContext.save()

        purchase.removeAccessory(accessories[1])

        XCTAssertFalse(accessories[0].hasChanges)
    }

    // MARK: moveAccessory

    /// Check that moving an accessory forwards works.
    func testMoveAccessoryForwards() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var accessories: [Accessory] = []
        for index in 0...5 {
            let accessory = Accessory(context: persistenceController.container.viewContext)
            accessory.index = Int16(clamping: index)
            purchase.addToAccessories(accessory)
            accessories.append(accessory)
            purchase.maxAccessoryIndex = accessory.index
        }

        purchase.moveAccessoryAt(4, to: 2)

        XCTAssertEqual(accessories[0].index, 0)
        XCTAssertEqual(accessories[1].index, 1)
        XCTAssertEqual(accessories[2].index, 3)
        XCTAssertEqual(accessories[3].index, 4)
        XCTAssertEqual(accessories[4].index, 2)
        XCTAssertEqual(accessories[5].index, 5)
    }

    /// Check that moving an accessory backwards works.
    func testMoveAccessoryBackwards() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var accessories: [Accessory] = []
        for index in 0...5 {
            let accessory = Accessory(context: persistenceController.container.viewContext)
            accessory.index = Int16(clamping: index)
            purchase.addToAccessories(accessory)
            accessories.append(accessory)
            purchase.maxAccessoryIndex = accessory.index
        }

        purchase.moveAccessoryAt(1, to: 3)

        XCTAssertEqual(accessories[0].index, 0)
        XCTAssertEqual(accessories[1].index, 3)
        XCTAssertEqual(accessories[2].index, 1)
        XCTAssertEqual(accessories[3].index, 2)
        XCTAssertEqual(accessories[4].index, 4)
        XCTAssertEqual(accessories[5].index, 5)
    }

    /// Check that moving an accessory to its existing location does nothing.
    func testMoveAccessoryToSameAccessory() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var accessories: [Accessory] = []
        for index in 0...5 {
            let accessory = Accessory(context: persistenceController.container.viewContext)
            accessory.index = Int16(clamping: index)
            purchase.addToAccessories(accessory)
            accessories.append(accessory)
            purchase.maxAccessoryIndex = accessory.index
        }

        purchase.moveAccessoryAt(4, to: 4)

        for (index, accessory) in accessories.enumerated() {
            XCTAssertEqual(accessory.index, Int16(clamping: index))
        }
    }

    /// Check that swapping two accessories forward in the middle of the set works.
    func testMoveAccessorySwapForwards() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var accessories: [Accessory] = []
        for index in 0...5 {
            let accessory = Accessory(context: persistenceController.container.viewContext)
            accessory.index = Int16(clamping: index)
            purchase.addToAccessories(accessory)
            accessories.append(accessory)
            purchase.maxAccessoryIndex = accessory.index
        }

        purchase.moveAccessoryAt(2, to: 3)

        XCTAssertEqual(accessories[0].index, 0)
        XCTAssertEqual(accessories[1].index, 1)
        XCTAssertEqual(accessories[2].index, 3)
        XCTAssertEqual(accessories[3].index, 2)
        XCTAssertEqual(accessories[4].index, 4)
        XCTAssertEqual(accessories[5].index, 5)
    }

    /// Check that swapping two accessories backward in the middle of the set works.
    func testMoveAccessorySwapBackwards() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var accessories: [Accessory] = []
        for index in 0...5 {
            let accessory = Accessory(context: persistenceController.container.viewContext)
            accessory.index = Int16(clamping: index)
            purchase.addToAccessories(accessory)
            accessories.append(accessory)
            purchase.maxAccessoryIndex = accessory.index
        }

        purchase.moveAccessoryAt(3, to: 2)

        XCTAssertEqual(accessories[0].index, 0)
        XCTAssertEqual(accessories[1].index, 1)
        XCTAssertEqual(accessories[2].index, 3)
        XCTAssertEqual(accessories[3].index, 2)
        XCTAssertEqual(accessories[4].index, 4)
        XCTAssertEqual(accessories[5].index, 5)
    }

    /// Check that we can swap two accessories forward.
    func testMoveAccessorySwapTwoForwards() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var accessories: [Accessory] = []
        for index in 0...1 {
            let accessory = Accessory(context: persistenceController.container.viewContext)
            accessory.index = Int16(clamping: index)
            purchase.addToAccessories(accessory)
            accessories.append(accessory)
            purchase.maxAccessoryIndex = accessory.index
        }

        purchase.moveAccessoryAt(1, to: 0)

        XCTAssertEqual(accessories[0].index, 1)
        XCTAssertEqual(accessories[1].index, 0)
    }

    /// Check that we can swap two accessories backward.
    func testMoveAccessorySwapTwoBackwards() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var accessories: [Accessory] = []
        for index in 0...1 {
            let accessory = Accessory(context: persistenceController.container.viewContext)
            accessory.index = Int16(clamping: index)
            purchase.addToAccessories(accessory)
            accessories.append(accessory)
            purchase.maxAccessoryIndex = accessory.index
        }

        purchase.moveAccessoryAt(0, to: 1)

        XCTAssertEqual(accessories[0].index, 1)
        XCTAssertEqual(accessories[1].index, 0)
    }

    /// Check that moving an accessory makes minimal changes to indexes.
    func testMoveMinimizesChanges() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        var accessories: [Accessory] = []
        for index in 0...5 {
            let accessory = Accessory(context: persistenceController.container.viewContext)
            accessory.index = Int16(clamping: index)
            purchase.addToAccessories(accessory)
            accessories.append(accessory)
            purchase.maxAccessoryIndex = accessory.index
        }

        try persistenceController.container.viewContext.save()

        purchase.moveAccessoryAt(1, to: 3)

        XCTAssertFalse(accessories[0].hasChanges)
        XCTAssertFalse(accessories[4].hasChanges)
    }
}
