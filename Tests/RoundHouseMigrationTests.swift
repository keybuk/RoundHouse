//
//  RoundHouseMigrationTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import XCTest
import CoreData

class RoundHouseMigrationTests: XCTestCase {
    var tempDirectoryURL: URL!

    var sourceURL: URL!
    var sourceManagedObjectModel: NSManagedObjectModel!

    var destinationURL: URL!
    var destinationManagedObjectModel: NSManagedObjectModel!

    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        tempDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true, attributes: nil)

        let sourceModelURL = try XCTUnwrap(Bundle.main.url(forResource: "RoundHouse.momd/EngineShed", withExtension: "mom"))
        sourceManagedObjectModel = try XCTUnwrap(NSManagedObjectModel(contentsOf: sourceModelURL))

        // Saving with the source managed object model will register the entities against their
        // class names, breaking all future unit tests.
        for entity in sourceManagedObjectModel.entities {
            entity.managedObjectClassName = "NSManagedObject"
        }

        sourceURL = tempDirectoryURL.appendingPathComponent("Source.sqlite")

        let destinationModelURL = try XCTUnwrap(Bundle.main.url(forResource: "RoundHouse.momd/RoundHouse", withExtension: "mom"))
        destinationManagedObjectModel = try XCTUnwrap(NSManagedObjectModel(contentsOf: destinationModelURL))

        // Since we don't save, this isn't necessary, but just to be safe...
        for entity in destinationManagedObjectModel.entities {
            entity.managedObjectClassName = "NSManagedObject"
        }

        destinationURL = tempDirectoryURL.appendingPathComponent("Destination.sqlite")

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: sourceManagedObjectModel)
        let _ = try persistentStoreCoordinator.addPersistentStore(type: .sqlite, configuration: nil, at: sourceURL, options: nil)

        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    }

    func performMigration() throws {
        let mappingModel = try XCTUnwrap(NSMappingModel(from: nil,
                                                        forSourceModel: sourceManagedObjectModel,
                                                        destinationModel: destinationManagedObjectModel))
        let migrationManager = NSMigrationManager(sourceModel: sourceManagedObjectModel,
                                                  destinationModel: destinationManagedObjectModel)

        try migrationManager.migrateStore(from: sourceURL, type: .sqlite, options: nil,
                                          mapping: mappingModel,
                                          to: destinationURL, type: .sqlite, options: nil)

        for persisentStore in managedObjectContext.persistentStoreCoordinator!.persistentStores {
            try managedObjectContext.persistentStoreCoordinator!.remove(persisentStore)
        }

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: destinationManagedObjectModel)
        let _ = try persistentStoreCoordinator.addPersistentStore(type: .sqlite, configuration: nil, at: destinationURL, options: nil)

        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    }

    override func tearDownWithError() throws {
        let persistentStoreCoordinator = managedObjectContext.persistentStoreCoordinator!
        managedObjectContext = nil

        sourceManagedObjectModel = nil
        destinationManagedObjectModel = nil

        for persisentStore in persistentStoreCoordinator.persistentStores {
            try persistentStoreCoordinator.remove(persisentStore)
        }

        try FileManager.default.removeItem(at: tempDirectoryURL)
    }

    // MARK: ModelToAccessory

    func testModelToAccessory() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")

        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(7, forKey: "classificationRawValue")
        sModel.setValue("Straight Track", forKey: "modelClass")
        sModel.setValue("Test".data(using: .utf8), forKey: "imageData")
        sModel.setValue("HO", forKey: "gauge")
        sModel.setValue("Some Notes", forKey: "notes")

        try managedObjectContext.save()
        try performMigration()

        let dPurchase = managedObjectContext.object(with: sPurchase.objectID)
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 0, "Unexpected models in purchase, should have been converted to accessory")

        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 1, "Expected accessories in purchase")

        let dAccessory = dAccessories[dAccessories.startIndex]
        XCTAssertEqual(dAccessory.value(forKey: "purchase") as! NSManagedObject?, dPurchase,
                       "purchase not copied from source Model")
        XCTAssertEqual(dAccessory.value(forKey: "manufacturer") as! String?, "Hornby",
                       "manufacturer not copied from source Purchase")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "Straight Track",
                       "catalogDescription not copied from source Model.modelClass")
        XCTAssertEqual(dAccessory.value(forKey: "imageData") as! Data?, "Test".data(using: .utf8),
                       "imageData not copied from source Model")
        XCTAssertEqual(dAccessory.value(forKey: "gauge") as! String?, "HO",
                       "gauge not copied from source Model")
        XCTAssertEqual(dAccessory.value(forKey: "notes") as! String?, "Some Notes",
                       "notes not copied from source Model")
    }

    func testModelToAccessoryHornby() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(7, forKey: "classificationRawValue")
        sModel.setValue("R600 Straight Track", forKey: "modelClass")

        try managedObjectContext.save()
        try performMigration()

        let dPurchase = managedObjectContext.object(with: sPurchase.objectID)
        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 1, "Expected accessories in purchase")

        let dAccessory = dAccessories[dAccessories.startIndex]
        XCTAssertEqual(dAccessory.value(forKey: "catalogNumber") as! String?, "R600",
                       "catalogNumber not extracted from source Model.modelClass")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "Straight Track",
                       "catalogDescription not extracted from source Model.modelClass")
    }

    func testModelToAccessoryBachmann() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(7, forKey: "classificationRawValue")
        sModel.setValue("36-420 Midland Pullman Stewards & Train Crew", forKey: "modelClass")

        try managedObjectContext.save()
        try performMigration()

        let dPurchase = managedObjectContext.object(with: sPurchase.objectID)
        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 1, "Expected accessories in purchase")

        let dAccessory = dAccessories[dAccessories.startIndex]
        XCTAssertEqual(dAccessory.value(forKey: "catalogNumber") as! String?, "36-420",
                       "catalogNumber not extracted from source Model.modelClass")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "Midland Pullman Stewards & Train Crew",
                       "catalogDescription not extracted from source Model.modelClass")
    }

    func testModelToAccessoryPeco() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(7, forKey: "classificationRawValue")
        sModel.setValue("SL-E180 Single Slip (Code 75)", forKey: "modelClass")

        try managedObjectContext.save()
        try performMigration()

        let dPurchase = managedObjectContext.object(with: sPurchase.objectID)
        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 1, "Expected accessories in purchase")

        let dAccessory = dAccessories[dAccessories.startIndex]
        XCTAssertEqual(dAccessory.value(forKey: "catalogNumber") as! String?, "SL-E180",
                       "catalogNumber not extracted from source Model.modelClass")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "Single Slip (Code 75)",
                       "catalogDescription not extracted from source Model.modelClass")
    }

    func testModelToAccessoryContainer() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(7, forKey: "classificationRawValue")
        sModel.setValue("45ft Container", forKey: "modelClass")

        try managedObjectContext.save()
        try performMigration()

        let dPurchase = managedObjectContext.object(with: sPurchase.objectID)
        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 1, "Expected accessories in purchase")

        let dAccessory = dAccessories[dAccessories.startIndex]
        XCTAssertEqual(dAccessory.value(forKey: "catalogNumber") as! String?, "",
                       "catalogNumber unexpectedly extracted from source Model.modelClass")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "45ft Container",
                       "catalogDescription not copied from source Model.modelClass")
    }
}
