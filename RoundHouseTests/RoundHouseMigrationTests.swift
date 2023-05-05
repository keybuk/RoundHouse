//
//  RoundHouseMigrationTests.swift
//  RoundHouseTests
//
//  Created by Scott James Remnant on 5/5/23.
//

import XCTest
import CoreData

@testable import RoundHouse

final class RoundHouseMigrationTests: XCTestCase {
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

    /// Perform a test migration from the source model to destination model.
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

    func testEmptyMigration() throws {
        try managedObjectContext.save()
        try performMigration()
    }

    // MARK: PurchaseToPurchase

    /// Check that expected fields are copied.
    func testPurchaseToPurchase() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")
        sPurchase.setValue("Express Train", forKey: "catalogDescription")
        sPurchase.setValue(2000, forKey: "catalogYear")
        sPurchase.setValue("Limited Edition", forKey: "limitedEdition")
        sPurchase.setValue(25, forKey: "limitedEditionNumber")
        sPurchase.setValue(500, forKey: "limitedEditionCount")
        sPurchase.setValue(DateComponents(year: 2010, month: 12, day: 25), forKey: "date")
        sPurchase.setValue("Hattons", forKey: "store")
        sPurchase.setValue(NSDecimalNumber(value: 129.99), forKey: "price")
        sPurchase.setValue(2, forKey: "conditionRawValue")
        sPurchase.setValue(NSDecimalNumber(value: 100), forKey: "valuation")
        sPurchase.setValue("Test", forKey: "notes")

        try managedObjectContext.save()
        try performMigration()

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected Purchase after migration")

        let dPurchase = dPurchases.first!
        XCTAssertEqual(dPurchase.value(forKey: "manufacturer") as! String?, "Hornby",
                       "Purchase.manufacturer not copied from source")
        XCTAssertEqual(dPurchase.value(forKey: "catalogNumber") as! String?, "R1234",
                       "Purchase.catalogNumber not copied from source")
        XCTAssertEqual(dPurchase.value(forKey: "catalogDescription") as! String?, "Express Train",
                       "Purchase.catalogDescription not copied from source")
        XCTAssertEqual(dPurchase.value(forKey: "catalogYear") as! Int16, 2000,
                       "Purchase.catalogYear not copied from source")
        XCTAssertEqual(dPurchase.value(forKey: "limitedEdition") as! String?, "Limited Edition",
                       "Purchase.limitedEdition not copied from source")
        XCTAssertEqual(dPurchase.value(forKey: "limitedEditionNumber") as! Int16, 25,
                       "Purchase.limitedEditionNumber not copied from source")
        XCTAssertEqual(dPurchase.value(forKey: "limitedEditionCount") as! Int16, 500,
                       "Purchase.limitedEditionCount not copied from source")
        XCTAssertEqual(dPurchase.value(forKey: "date") as! Date?,
                       calendar.date(from: DateComponents(year: 2010, month: 12, day: 25)),
                       "Purchase.date not converted from source")
        XCTAssertEqual(dPurchase.value(forKey: "store") as! String?, "Hattons",
                       "Purchase.store not copied from source")
        XCTAssertEqual(dPurchase.value(forKey: "priceRawValue") as! NSDecimalNumber?,
                       NSDecimalNumber(value: 129.99),
                       "Purchase.price not copied from source Purchase")
        XCTAssertEqual(dPurchase.value(forKey: "conditionRawValue") as! Int16,
                       Purchase.Condition.likeNew.rawValue,
                       "Purchase.conditionRawValue not copied from source")
        XCTAssertEqual(dPurchase.value(forKey: "valuationRawValue") as! NSDecimalNumber?,
                       NSDecimalNumber(value: 100),
                       "Purchase.valuation not copied from source")
        XCTAssertEqual(dPurchase.value(forKey: "notes") as! String?, "Test",
                       "Purchase.notes not copied from source")
    }

    /// Check that nil string fields are converted to an empty string.
    func testPurchaseNilEmptyString() throws {
        let _ = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                insertInto: managedObjectContext)

        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected Purchase after migration")

        let dPurchase = dPurchases.first!
        XCTAssertEqual(dPurchase.value(forKey: "manufacturer") as! String?, "",
                       "Purchase.manufacturer not converted to empty string")
        XCTAssertEqual(dPurchase.value(forKey: "catalogNumber") as! String?, "",
                       "Purchase.catalogNumber not converted to empty string")
        XCTAssertEqual(dPurchase.value(forKey: "catalogDescription") as! String?, "",
                       "Purchase.catalogDescription not converted to empty string")
        XCTAssertEqual(dPurchase.value(forKey: "limitedEdition") as! String?, "",
                       "Purchase.limitedEdition not converted to empty string")
        XCTAssertEqual(dPurchase.value(forKey: "store") as! String?, "",
                       "Purchase.store not converted to empty string")
        XCTAssertEqual(dPurchase.value(forKey: "notes") as! String?, "",
                       "Purchase.notes not converted to empty string")
    }

    /// Check that the catalogNumberPrefix field is populated during migration.
    func testPurchaseCatalogNumberPrefix() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234A", forKey: "catalogNumber")

        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected Purchase after migration")

        let dPurchase = dPurchases.first!
        XCTAssertEqual(dPurchase.value(forKey: "catalogNumberPrefix") as! String?, "R1234",
                       "Purchase.catalogNumberPrefix not set during migration")
    }

    /// Check that the catalogNumberPrefix field is set to empty string when catalogNumber is unset.
    func testPurchaseNilCatalogNumberPrefix() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")

        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected Purchase after migration")

        let dPurchase = dPurchases.first!
        XCTAssertEqual(dPurchase.value(forKey: "catalogNumberPrefix") as! String?, "",
                       "Purchase.catalogNumberPrefix not set during migration")
    }

    /// Check that the price locale codes are converted to currency codes.
    func testPriceCurrencyGBP() throws {
        let currencyMap = [
            ("en_GB", "GBP"),
            ("en_US", "USD"),
        ]

        for (localeIdentifier, _) in currencyMap {
            let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                            insertInto: managedObjectContext)
            sPurchase.setValue(localeIdentifier, forKey: "catalogNumber")
            sPurchase.setValue(localeIdentifier, forKey: "priceCurrency")
        }

        try managedObjectContext.save()
        try performMigration()

        for (localeIdentifier, currencyIdentifier) in currencyMap {
            let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
            dPurchasesFetchRequest.predicate = NSPredicate(format: "catalogNumber = %@", localeIdentifier)
            let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
            XCTAssertEqual(dPurchases.count, 1, "Expected Purchase after migration")

            let dPurchase = dPurchases.first!
            XCTAssertEqual(dPurchase.value(forKey: "priceCurrency") as! String?, currencyIdentifier,
                           "Purchase.priceCurrency not correctly converted")
        }
    }

    /// Check that the valuation locale codes are converted to currency codes.
    func testValuationCurrencyGBP() throws {
        let currencyMap = [
            ("en_GB", "GBP"),
            ("en_US", "USD"),
        ]

        for (localeIdentifier, _) in currencyMap {
            let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                            insertInto: managedObjectContext)
            sPurchase.setValue(localeIdentifier, forKey: "catalogNumber")
            sPurchase.setValue(localeIdentifier, forKey: "valuationCurrency")
        }

        try managedObjectContext.save()
        try performMigration()

        for (localeIdentifier, currencyIdentifier) in currencyMap {
            let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
            dPurchasesFetchRequest.predicate = NSPredicate(format: "catalogNumber = %@", localeIdentifier)
            let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
            XCTAssertEqual(dPurchases.count, 1, "Expected Purchase after migration")

            let dPurchase = dPurchases.first!
            XCTAssertEqual(dPurchase.value(forKey: "valuationCurrency") as! String?, currencyIdentifier,
                           "Purchase.valuationCurrency not correctly converted")
        }
    }

    /// Check that models retain their order.
    func testModelIndexes() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")
        sPurchase.setValue(1, forKey: "maxModelIndex")

        let sModel1 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel1.setValue(sPurchase, forKey: "purchase")
        sModel1.setValue("One", forKey: "modelClass")
        sModel1.setValue(0, forKey: "index")

        let sModel2 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel2.setValue(sPurchase, forKey: "purchase")
        sModel2.setValue("Two", forKey: "modelClass")
        sModel2.setValue(1, forKey: "index")

        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected Purchase after migration")

        let dPurchase = dPurchases.first!
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 2, "Expected Model in Purchase")

        let sortedModels = dModels.sorted {
            ($0.value(forKey: "index") as! Int16) < ($1.value(forKey: "index") as! Int16)
        }

        XCTAssertEqual(sortedModels[0].value(forKey: "modelClass") as! String?, "One",
                       "Purchase.models in incorrect order")
        XCTAssertEqual(sortedModels[0].value(forKey: "index") as! Int16, 0,
                       "Model.index has incorrect value")

        XCTAssertEqual(sortedModels[1].value(forKey: "modelClass") as! String?, "Two",
                       "Purchase.models in incorrect order")
        XCTAssertEqual(sortedModels[1].value(forKey: "index") as! Int16, 1,
                       "Model.index has incorrect value")

        XCTAssertEqual(dPurchase.value(forKey: "maxModelIndex") as! Int16, 1,
                       "Purchase.maxModelIndex not correctly calculated")

        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 0, "Unexpected Accessory in Purchase")

        XCTAssertEqual(dPurchase.value(forKey: "maxAccessoryIndex") as! Int16, -1,
                       "Purchase.maxAccessoryIndex not correctly calculated")
    }

    /// Check that models retain their order when converted to accesories.
    func testAccessoryIndexes() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")
        sPurchase.setValue(1, forKey: "maxModelIndex")

        let sModel1 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel1.setValue(sPurchase, forKey: "purchase")
        sModel1.setValue(7, forKey: "classificationRawValue")
        sModel1.setValue("One", forKey: "modelClass")
        sModel1.setValue(0, forKey: "index")

        let sModel2 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel2.setValue(sPurchase, forKey: "purchase")
        sModel2.setValue(7, forKey: "classificationRawValue")
        sModel2.setValue("Two", forKey: "modelClass")
        sModel2.setValue(1, forKey: "index")

        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected Purchase after migration")

        let dPurchase = dPurchases.first!
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 0, "Unexpected Model in Purchase")

        XCTAssertEqual(dPurchase.value(forKey: "maxModelIndex") as! Int16, -1,
                       "Purchase.maxModelIndex not correctly calculated")

        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 2, "Expected Accessory in Purchase")

        let sortedAccessories = dAccessories.sorted {
            ($0.value(forKey: "index") as! Int16) < ($1.value(forKey: "index") as! Int16)
        }

        XCTAssertEqual(sortedAccessories[0].value(forKey: "catalogDescription") as! String?, "One",
                       "Purchase.accessories in incorrect order")
        XCTAssertEqual(sortedAccessories[0].value(forKey: "index") as! Int16, 0,
                       "Accessory.index has incorrect value")

        XCTAssertEqual(sortedAccessories[1].value(forKey: "catalogDescription") as! String?, "Two",
                       "Purchase.accessories in incorrect order")
        XCTAssertEqual(sortedAccessories[1].value(forKey: "index") as! Int16, 1,
                       "Accessory.index has incorrect value")

        XCTAssertEqual(dPurchase.value(forKey: "maxAccessoryIndex") as! Int16, 1,
                       "Purchase.maxAccessoryIndex not correctly calculated")
    }

    /// Check that models and accessories retain their order when some are converted to accesories.
    func testModelAndAccessoryIndexes() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")
        sPurchase.setValue(1, forKey: "maxModelIndex")

        let sModel1 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel1.setValue(sPurchase, forKey: "purchase")
        sModel1.setValue("One", forKey: "modelClass")
        sModel1.setValue(0, forKey: "index")

        let sModel2 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel2.setValue(sPurchase, forKey: "purchase")
        sModel2.setValue(7, forKey: "classificationRawValue")
        sModel2.setValue("Two", forKey: "modelClass")
        sModel2.setValue(1, forKey: "index")

        let sModel3 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel3.setValue(sPurchase, forKey: "purchase")
        sModel3.setValue("Three", forKey: "modelClass")
        sModel3.setValue(2, forKey: "index")

        let sModel4 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel4.setValue(sPurchase, forKey: "purchase")
        sModel4.setValue(7, forKey: "classificationRawValue")
        sModel4.setValue("Four", forKey: "modelClass")
        sModel4.setValue(3, forKey: "index")

        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected Purchase after migration")

        let dPurchase = dPurchases.first!
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 2, "Expected Model in Purchase")

        let sortedModels = dModels.sorted {
            ($0.value(forKey: "index") as! Int16) < ($1.value(forKey: "index") as! Int16)
        }

        XCTAssertEqual(sortedModels[0].value(forKey: "modelClass") as! String?, "One",
                       "Purchase.models in incorrect order")
        XCTAssertEqual(sortedModels[0].value(forKey: "index") as! Int16, 0,
                       "Model.index has incorrect value")

        XCTAssertEqual(sortedModels[1].value(forKey: "modelClass") as! String?, "Three",
                       "Purchase.models in incorrect order")
        XCTAssertEqual(sortedModels[1].value(forKey: "index") as! Int16, 1,
                       "Model.index has incorrect value")

        XCTAssertEqual(dPurchase.value(forKey: "maxModelIndex") as! Int16, 1,
                       "Purchase.maxModelIndex not correctly calculated")

        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 2, "Expected Accessory in Purchase")

        let sortedAccessories = dAccessories.sorted {
            ($0.value(forKey: "index") as! Int16) < ($1.value(forKey: "index") as! Int16)
        }

        XCTAssertEqual(sortedAccessories[0].value(forKey: "catalogDescription") as! String?, "Two",
                       "Purchase.accessories in incorrect order")
        XCTAssertEqual(sortedAccessories[0].value(forKey: "index") as! Int16, 0,
                       "Accessory.index has incorrect value")

        XCTAssertEqual(sortedAccessories[1].value(forKey: "catalogDescription") as! String?, "Four",
                       "Purchase.accessories in incorrect order")
        XCTAssertEqual(sortedAccessories[1].value(forKey: "index") as! Int16, 1,
                       "Accessory.index has incorrect value")

        XCTAssertEqual(dPurchase.value(forKey: "maxAccessoryIndex") as! Int16, 1,
                       "Purchase.maxAccessoryIndex not correctly calculated")
    }

    // MARK: ModelToModel

    /// Check that expected fields are copied.
    func testModelToModel() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")

        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue("test".data(using: .utf8), forKey: "imageData")
        sModel.setValue("LNER A4", forKey: "modelClass")
        sModel.setValue("4-6-2", forKey: "wheelArrangement")
        sModel.setValue("HO", forKey: "gauge")
        sModel.setValue("Boris Johnson", forKey: "name")
        sModel.setValue("4600", forKey: "number")
        sModel.setValue("BR Blue", forKey: "livery")
        sModel.setValue("Great British Railways", forKey: "details")
        sModel.setValue(11, forKey: "eraRawValue")
        sModel.setValue(2, forKey: "dispositionRawValue")
        sModel.setValue("5-pole", forKey: "motor")
        sModel.setValue(DateComponents(year: 2020, month: 6, day: 17), forKey: "lastOil")
        sModel.setValue(DateComponents(year: 2020, month: 6, day: 19), forKey: "lastRun")
        sModel.setValue("Test", forKey: "notes")

        try managedObjectContext.save()
        try performMigration()

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!

        let dModelsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Model")
        let dModels = try managedObjectContext.fetch(dModelsFetchRequest)
        XCTAssertEqual(dModels.count, 1, "Expected Model after migration")

        let dModel = dModels.first!
        XCTAssertNotNil(dModel.value(forKey: "purchase"),
                        "Model.purchase not set from source")
        XCTAssertEqual(dModel.value(forKey: "imageData") as! Data?,
                       "test".data(using: .utf8),
                       "Model.imageData not copied from source")
        XCTAssertEqual(dModel.value(forKey: "modelClass") as! String?, "LNER A4",
                       "Model.modelClass not copied from source")
        XCTAssertEqual(dModel.value(forKey: "wheelArrangement") as! String?, "4-6-2",
                       "Model.wheelArrangement not copied from source")
        XCTAssertEqual(dModel.value(forKey: "gauge") as! String?, "HO",
                       "Model.gauge not copied from source")
        XCTAssertEqual(dModel.value(forKey: "name") as! String?, "Boris Johnson",
                       "Model.name not copied from source")
        XCTAssertEqual(dModel.value(forKey: "number") as! String?, "4600",
                       "Model.number not copied from source")
        XCTAssertEqual(dModel.value(forKey: "livery") as! String?, "BR Blue",
                       "Model.livery not copied from source")
        XCTAssertEqual(dModel.value(forKey: "details") as! String?, "Great British Railways",
                       "Model.details not copied from source")
        XCTAssertEqual(dModel.value(forKey: "eraRawValue") as! Int16,
                       Model.Era.currentEra.rawValue,
                       "Model.eraRawValue not copied from source")
        XCTAssertEqual(dModel.value(forKey: "dispositionRawValue") as! Int16,
                       Model.Disposition.collectorItem.rawValue,
                       "Model.dispositionRawValue not copied from source")
        XCTAssertEqual(dModel.value(forKey: "motor") as! String?, "5-pole",
                       "Model.motor not copied from source")
        XCTAssertEqual(dModel.value(forKey: "lastOilDate") as! Date?,
                       calendar.date(from: DateComponents(year: 2020, month: 6, day: 17)),
                       "Model.lastOilDate not converted from source")
        XCTAssertEqual(dModel.value(forKey: "lastRunDate") as! Date?,
                       calendar.date(from: DateComponents(year: 2020, month: 6, day: 19)),
                       "Model.lastRunDate not converted from source")
        XCTAssertEqual(dModel.value(forKey: "notes") as! String?, "Test",
                       "Model.notes not copied from source")
    }

    /// Check that nil string fields are converted to an empty string.
    func testModelNilEmptyString() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")

        let _ = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)

        try managedObjectContext.save()
        try performMigration()

        let dModelsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Model")
        let dModels = try managedObjectContext.fetch(dModelsFetchRequest)
        XCTAssertEqual(dModels.count, 1, "Expected Model after migration")

        let dModel = dModels.first!
        XCTAssertEqual(dModel.value(forKey: "modelClass") as! String?, "",
                       "Model.modelClass not converted to empty string")
        XCTAssertEqual(dModel.value(forKey: "wheelArrangement") as! String?, "",
                       "Model.wheelArrangement not converted to empty string")
        // Gauge is defaulted to "OO" so will never be nil.
        XCTAssertEqual(dModel.value(forKey: "name") as! String?, "",
                       "Model.name not converted to empty string")
        XCTAssertEqual(dModel.value(forKey: "number") as! String?, "",
                       "Model.number not converted to empty string")
        XCTAssertEqual(dModel.value(forKey: "livery") as! String?, "",
                       "Model.livery not converted to empty string")
        XCTAssertEqual(dModel.value(forKey: "details") as! String?, "",
                       "Model.details not converted to empty string")
        XCTAssertEqual(dModel.value(forKey: "motor") as! String?, "",
                       "Model.motor not converted to empty string")
        XCTAssertEqual(dModel.value(forKey: "notes") as! String?, "",
                       "Model.notes not converted to empty string")
    }

    /// Check that classifications are renumbered.
    func testModelClassification() throws {
        let classificationMap = [
            (1, Model.Classification.dieselElectricLocomotive),
            (2, Model.Classification.coach),
            (3, Model.Classification.wagon),
            (4, Model.Classification.multipleUnit),
            (5, Model.Classification.departmental),
            (6, Model.Classification.noPrototype),
            (8, Model.Classification.vehicle),
            (9, Model.Classification.steamLocomotive),
        ]

        for (oldRawValue, _) in classificationMap {
            let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                            insertInto: managedObjectContext)
            sPurchase.setValue("Hornby", forKey: "manufacturer")
            sPurchase.setValue("R\(oldRawValue)", forKey: "catalogNumber")

            let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                         insertInto: managedObjectContext)
            sModel.setValue(sPurchase, forKey: "purchase")
            sModel.setValue(oldRawValue, forKey: "classificationRawValue")
        }

        try managedObjectContext.save()
        try performMigration()

        for (oldRawValue, newValue) in classificationMap {
            let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
            dPurchasesFetchRequest.predicate = NSPredicate(format: "catalogNumber = %@", "R\(oldRawValue)")
            let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
            XCTAssertEqual(dPurchases.count, 1, "Expected Purchase after migration")
            
            let dPurchase = dPurchases.first!
            let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
            XCTAssertEqual(dModels.count, 1, "Expected Model in Purchase")
            
            let dModel = dModels[dModels.startIndex]
            XCTAssertEqual(dModel.value(forKey: "classificationRawValue") as! Int16, newValue.rawValue,
                           "Model.classificationRawValue has incorrect value after migration")
        }
    }

    // MARK: ModelToAccessory

    /// Check that an old accessory Model is converted to Accessory with all properties copied.
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

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected Purchase after migration")

        let dPurchase = dPurchases.first!
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 0, "Unexpected Model in Purchase, should have been converted to Accessory")

        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 1, "Expected Accessory in purchase")

        let dAccessory = dAccessories[dAccessories.startIndex]
        XCTAssertEqual(dAccessory.value(forKey: "purchase") as! NSManagedObject?, dPurchase,
                       "Accessory.purchase not copied from source Model")
        XCTAssertEqual(dAccessory.value(forKey: "manufacturer") as! String?, "Hornby",
                       "Accessory.manufacturer not copied from source Purchase")
        XCTAssertEqual(dAccessory.value(forKey: "catalogNumber") as! String?, "",
                       "Accessory.catalogNumber not set to empty string")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "Straight Track",
                       "Accessory.catalogDescription not copied from source Model.modelClass")
        XCTAssertEqual(dAccessory.value(forKey: "imageData") as! Data?, "Test".data(using: .utf8),
                       "Accessory.imageData not copied from source Model")
        XCTAssertEqual(dAccessory.value(forKey: "gauge") as! String?, "HO",
                       "Accessory.gauge not copied from source Model")
        XCTAssertEqual(dAccessory.value(forKey: "notes") as! String?, "Some Notes",
                       "Accessory.notes not copied from source Model")
    }

    /// Check that nil values are converted to empty string when an old accessory Model is converted to Accessory.
    func testModelToAccessoryNilToEmptyString() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)

        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(7, forKey: "classificationRawValue")

        try managedObjectContext.save()
        try performMigration()

        let dAccessoriesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Accessory")
        let dAccessories = try managedObjectContext.fetch(dAccessoriesFetchRequest)
        XCTAssertEqual(dAccessories.count, 1, "Expected Accessory after migration")

        let dAccessory = dAccessories.first!
        XCTAssertEqual(dAccessory.value(forKey: "manufacturer") as! String?, "",
                       "Accessory.manufacturer not converted from empty string")
        XCTAssertEqual(dAccessory.value(forKey: "catalogNumber") as! String?, "",
                       "Accessory.catalogNumber not converted from empty string")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "",
                       "Accessory.catalogDescription not converted from empty string")
        XCTAssertEqual(dAccessory.value(forKey: "notes") as! String?, "",
                       "Accessory.notes not converted from empty string")
    }

    /// Check that an old modelClass containing a Hornby catalog number is extracted.
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

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected Purchase after migration")

        let dPurchase = dPurchases.first!
        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 1, "Expected Accessory in Purchase")

        let dAccessory = dAccessories[dAccessories.startIndex]
        XCTAssertEqual(dAccessory.value(forKey: "catalogNumber") as! String?, "R600",
                       "Accessory.catalogNumber not extracted from source Model.modelClass")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "Straight Track",
                       "Accessory.catalogDescription not extracted from source Model.modelClass")
    }

    /// Check that an old modelClass containing a Bachmann catalog number is extracted.
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

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected Purchase after migration")

        let dPurchase = dPurchases.first!
        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 1, "Expected Accessory in purchase")

        let dAccessory = dAccessories[dAccessories.startIndex]
        XCTAssertEqual(dAccessory.value(forKey: "catalogNumber") as! String?, "36-420",
                       "Accessory.catalogNumber not extracted from source Model.modelClass")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "Midland Pullman Stewards & Train Crew",
                       "Accessory.catalogDescription not extracted from source Model.modelClass")
    }

    /// Check that an old modelClass containing a PECO catalog number is extracted.
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

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected Purchase after migration")

        let dPurchase = dPurchases.first!
        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 1, "Expected Accessory in Purchase")

        let dAccessory = dAccessories[dAccessories.startIndex]
        XCTAssertEqual(dAccessory.value(forKey: "catalogNumber") as! String?, "SL-E180",
                       "Accessory.catalogNumber not extracted from source Model.modelClass")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "Single Slip (Code 75)",
                       "Accessory.catalogDescription not extracted from source Model.modelClass")
    }

    /// Check that an old modelClass containing a container size isn't extracted as a catalog number.
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

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected Purchase after migration")

        let dPurchase = dPurchases.first!
        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 1, "Expected Accessory in Purchase")

        let dAccessory = dAccessories[dAccessories.startIndex]
        XCTAssertEqual(dAccessory.value(forKey: "catalogNumber") as! String?, "",
                       "Accessory.catalogNumber unexpectedly extracted from source Model.modelClass")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "45ft Container",
                       "Accessory.catalogDescription not copied from source Model.modelClass")
    }

    // MARK: DecoderTypeToDecoderType

    /// Check that expected fields are copied.
    func testDecoderTypeToDecoderType() throws {
        let sDecoderType = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                        insertInto: managedObjectContext)
        sDecoderType.setValue("ESU", forKey: "manufacturer")
        sDecoderType.setValue("50123", forKey: "productCode")
        sDecoderType.setValue("LokSound", forKey: "productFamily")
        sDecoderType.setValue("LokSound PluX22", forKey: "productDescription")
        sDecoderType.setValue("Test".data(using: .utf8), forKey: "imageData")
        sDecoderType.setValue(true, forKey: "isProgrammable")
        sDecoderType.setValue(true, forKey: "isSoundSupported")
        sDecoderType.setValue(true, forKey: "isRailComSupported")
        sDecoderType.setValue(10, forKey: "minimumStock")

        try managedObjectContext.save()
        try performMigration()

        let dDecoderTypesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DecoderType")
        let dDecoderTypes = try managedObjectContext.fetch(dDecoderTypesFetchRequest)
        XCTAssertEqual(dDecoderTypes.count, 1, "Expected DecoderType after migration")

        let dDecoderType = dDecoderTypes.first!
        XCTAssertEqual(dDecoderType.value(forKey: "manufacturer") as! String?, "ESU",
                       "DecoderType.manufacturer not copied from source")
        XCTAssertEqual(dDecoderType.value(forKey: "catalogNumber") as! String?, "50123",
                       "DecoderType.catalogNumber not copied from source productCode")
        XCTAssertEqual(dDecoderType.value(forKey: "catalogFamily") as! String?, "LokSound",
                       "DecoderType.catalogFamily not copied from source productFamily")
        XCTAssertEqual(dDecoderType.value(forKey: "catalogName") as! String?, "LokSound",
                       "DecoderType.catalogName not copied from source productFamily")
        XCTAssertEqual(dDecoderType.value(forKey: "catalogDescription") as! String?, "LokSound PluX22",
                       "DecoderType.catalogDescription not copied from source productDescription")
        XCTAssertEqual(dDecoderType.value(forKey: "imageData") as! Data?, "Test".data(using: .utf8),
                       "DecoderType.imageData not copied from source")
        XCTAssertEqual(dDecoderType.value(forKey: "isProgrammable") as! Bool, true,
                       "DecoderType.isProgrammable not copied from source")
        XCTAssertEqual(dDecoderType.value(forKey: "isSoundSupported") as! Bool, true,
                       "DecoderType.isSoundSupported not copied from source")
        XCTAssertEqual(dDecoderType.value(forKey: "isRailComSupported") as! Bool, true,
                       "DecoderType.isRailComSupported not copied from source")
        XCTAssertEqual(dDecoderType.value(forKey: "minimumStock") as! Int16, 10,
                       "DecoderType.minimumStock not copied from source")
    }

    /// Check that nil string fields are converted to an empty string.
    func testDecoderTypeNilEmptyString() throws {
        let _ = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                insertInto: managedObjectContext)

        try managedObjectContext.save()
        try performMigration()

        let dDecoderTypesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DecoderType")
        let dDecoderTypes = try managedObjectContext.fetch(dDecoderTypesFetchRequest)
        XCTAssertEqual(dDecoderTypes.count, 1, "Expected DecoderType after migration")

        let dDecoderType = dDecoderTypes.first!
        XCTAssertEqual(dDecoderType.value(forKey: "manufacturer") as! String?, "",
                       "DecoderType.manufacturer not converted to empty string")
        XCTAssertEqual(dDecoderType.value(forKey: "catalogNumber") as! String?, "",
                       "DecoderType.catalogNumber not converted to empty string")
        XCTAssertEqual(dDecoderType.value(forKey: "catalogName") as! String?, "",
                       "DecoderType.catalogName not converted to empty string")
        XCTAssertEqual(dDecoderType.value(forKey: "catalogFamily") as! String?, "",
                       "DecoderType.catalogFamily not converted to empty string")
        XCTAssertEqual(dDecoderType.value(forKey: "catalogDescription") as! String?, "",
                       "DecoderType.catalogDescription not converted to empty string")
    }

    /// Check that the reminaingStock field is populated during migration.
    func testDecoderTypeRemainingStock() throws {
        let sDecoderType = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                        insertInto: managedObjectContext)

        let sDecoder1 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Decoder"]!,
                                      insertInto: managedObjectContext)
        sDecoder1.setValue(sDecoderType, forKey: "type")

        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")

        let sDecoder2 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Decoder"]!,
                                      insertInto: managedObjectContext)
        sDecoder2.setValue(sDecoderType, forKey: "type")
        sDecoder2.setValue(sModel, forKey: "model")

        let sDecoder3 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Decoder"]!,
                                      insertInto: managedObjectContext)
        sDecoder3.setValue(sDecoderType, forKey: "type")

        let sDecoder4 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Decoder"]!,
                                      insertInto: managedObjectContext)
        sDecoder4.setValue(sDecoderType, forKey: "type")
        sDecoder4.setValue("Legomanbiffo", forKey: "soundAuthor")
        sDecoder4.setValue("Class 68", forKey: "soundProject")
        sDecoder4.setValue("1.0", forKey: "soundProjectVersion")
        sDecoder4.setValue("Newer Horns (CV43 = 1)", forKey: "soundSettings")

        try managedObjectContext.save()
        try performMigration()

        let dDecoderTypesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DecoderType")
        let dDecoderTypes = try managedObjectContext.fetch(dDecoderTypesFetchRequest)
        XCTAssertEqual(dDecoderTypes.count, 1, "Expected DecoderType after migration")

        let dDecoderType = dDecoderTypes.first!
        XCTAssertEqual(dDecoderType.value(forKey: "remainingStock") as! Int16, 2,
                       "DecoderType.reminaingStock not set during migration")
    }

    /// Check that the reminaingStock field is set to zero string when the type has no decoders.
    func testDecoderTypeEmptyRemainingStock() throws {
        let _ = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                insertInto: managedObjectContext)

        try managedObjectContext.save()
        try performMigration()

        let dDecoderTypesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DecoderType")
        let dDecoderTypes = try managedObjectContext.fetch(dDecoderTypesFetchRequest)
        XCTAssertEqual(dDecoderTypes.count, 1, "Expected DecoderType after migration")

        let dDecoderType = dDecoderTypes.first!
        XCTAssertEqual(dDecoderType.value(forKey: "remainingStock") as! Int16, 0,
                       "DecoderType.reminaingStock not set during migration")
    }

    // MARK: DecoderToDecoder

    /// Check that expected fields are copied.
    func testDecoderToDecoder() throws {
        let sDecoderType = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                        insertInto: managedObjectContext)

        let sDecoder = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Decoder"]!,
                                      insertInto: managedObjectContext)
        sDecoder.setValue(sDecoderType, forKey: "type")
        sDecoder.setValue(3, forKey: "address")
        sDecoder.setValue("CAFEF00D", forKey: "serialNumber")
        sDecoder.setValue("3.11", forKey: "firmwareVersion")
        sDecoder.setValue(DateComponents(year: 2019, month: 9, day: 15), forKey: "firmwareDate")
        sDecoder.setValue("Legomanbiffo", forKey: "soundAuthor")
        sDecoder.setValue("A4", forKey: "soundProject")
        sDecoder.setValue("V12", forKey: "soundProjectVersion")
        sDecoder.setValue("CV14.1=0", forKey: "soundSettings")

        try managedObjectContext.save()
        try performMigration()

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!

        let dDecodersFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Decoder")
        let dDecoders = try managedObjectContext.fetch(dDecodersFetchRequest)
        XCTAssertEqual(dDecoders.count, 1, "Expected Decoder after migration")

        let dDecoder = dDecoders.first!
        XCTAssertNotNil(dDecoder.value(forKey: "type"),
                        "Decoder.type not copied from source")
        XCTAssertEqual(dDecoder.value(forKey: "address") as! Int16, 3,
                       "Decoder.address not copied from source")
        XCTAssertEqual(dDecoder.value(forKey: "serialNumber") as! String?, "CAFEF00D",
                       "Decoder.serialNumber not copied from source")
        XCTAssertEqual(dDecoder.value(forKey: "firmwareVersion") as! String?, "3.11",
                       "Decoder.firmwareVersion not copied from source")
        XCTAssertEqual(dDecoder.value(forKey: "firmwareDate") as! Date?,
                       calendar.date(from: DateComponents(year: 2019, month: 9, day: 15)),
                       "Decoder.firmwareDate not converted from source")
        XCTAssertEqual(dDecoder.value(forKey: "soundAuthor") as! String?, "Legomanbiffo",
                       "Decoder.soundAuthor not copied from source")
        XCTAssertEqual(dDecoder.value(forKey: "soundProject") as! String?, "A4",
                       "Decoder.soundProject not copied from source")
        XCTAssertEqual(dDecoder.value(forKey: "soundProjectVersion") as! String?, "V12",
                       "Decoder.soundProjectVersion not copied from source")
        XCTAssertEqual(dDecoder.value(forKey: "soundSettings") as! String?, "CV14.1=0",
                       "Decoder.soundSettings not copied from source")
    }

    /// Check that nil string fields are converted to an empty string.
    func testDecoderNilEmptyString() throws {
        let sDecoderType = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                        insertInto: managedObjectContext)

        let sDecoder = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Decoder"]!,
                                      insertInto: managedObjectContext)
        sDecoder.setValue(sDecoderType, forKey: "type")

        try managedObjectContext.save()
        try performMigration()

        let dDecodersFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Decoder")
        let dDecoders = try managedObjectContext.fetch(dDecodersFetchRequest)
        XCTAssertEqual(dDecoders.count, 1, "Expected Decoder after migration")

        let dDecoder = dDecoders.first!
        XCTAssertEqual(dDecoder.value(forKey: "serialNumber") as! String?, "",
                       "Decoder.serialNumber not converted to empty string")
        XCTAssertEqual(dDecoder.value(forKey: "firmwareVersion") as! String?, "",
                       "Decoder.firmwareVersion not converted to empty string")
        XCTAssertEqual(dDecoder.value(forKey: "soundAuthor") as! String?, "",
                       "Decoder.soundAuthor not converted to empty string")
        XCTAssertEqual(dDecoder.value(forKey: "soundProject") as! String?, "",
                       "Decoder.soundProject not converted to empty string")
        XCTAssertEqual(dDecoder.value(forKey: "soundProjectVersion") as! String?, "",
                       "Decoder.soundProjectVersion not converted to empty string")
        XCTAssertEqual(dDecoder.value(forKey: "soundSettings") as! String?, "",
                       "Decoder.soundSettings not converted to empty string")
    }

    // MARK: TrainToTrain

    /// Check that expected fields are copied.
    func testTrainToTrain() throws {
        let sTrain = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Train"]!,
                                        insertInto: managedObjectContext)
        sTrain.setValue("Hogwarts Express", forKey: "name")
        sTrain.setValue("9 3/4", forKey: "number")
        sTrain.setValue("Chamber of Secrets", forKey: "details")
        sTrain.setValue("Hogwarts Castle and Coaches", forKey: "trainDescription")
        sTrain.setValue("Test", forKey: "notes")

        try managedObjectContext.save()
        try performMigration()

        let dTrainsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Train")
        let dTrains = try managedObjectContext.fetch(dTrainsFetchRequest)
        XCTAssertEqual(dTrains.count, 1, "Expected Train after migration")

        let dTrain = dTrains.first!
        XCTAssertEqual(dTrain.value(forKey: "name") as! String?, "Hogwarts Express",
                       "Train.name not copied from source")
        XCTAssertEqual(dTrain.value(forKey: "number") as! String?, "9 3/4",
                       "Train.number not copied from source")
        XCTAssertEqual(dTrain.value(forKey: "details") as! String?, "Chamber of Secrets",
                       "Train.details not copied from source")
        XCTAssertEqual(dTrain.value(forKey: "trainDescription") as! String?, "Hogwarts Castle and Coaches",
                       "Train.trainDescription not copied from source")
        XCTAssertEqual(dTrain.value(forKey: "notes") as! String?, "Test",
                       "Train.notes not copied from source")
    }

    /// Check that nil string fields are converted to an empty string.
    func testTrainNilEmptyString() throws {
        let _ = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Train"]!,
                                insertInto: managedObjectContext)

        try managedObjectContext.save()
        try performMigration()

        let dTrainsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Train")
        let dTrains = try managedObjectContext.fetch(dTrainsFetchRequest)
        XCTAssertEqual(dTrains.count, 1, "Expected trains after migration")

        let dTrain = dTrains.first!
        XCTAssertEqual(dTrain.value(forKey: "name") as! String?, "",
                       "Train.name not converted to empty string")
        XCTAssertEqual(dTrain.value(forKey: "number") as! String?, "",
                       "Train.number not converted to empty string")
        XCTAssertEqual(dTrain.value(forKey: "details") as! String?, "",
                       "Train.details not converted to empty string")
        XCTAssertEqual(dTrain.value(forKey: "trainDescription") as! String?, "",
                       "Train.trainDescription not converted to empty string")
        XCTAssertEqual(dTrain.value(forKey: "notes") as! String?, "",
                       "Train.notes not converted to empty string")
    }

    /// Check that train members retain their order.
    func testTrainMemberIndexes() throws {
        let sTrain = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Train"]!,
                                     insertInto: managedObjectContext)
        sTrain.setValue(1, forKey: "maxMemberIndex")

        let sTrainMember1 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["TrainMember"]!,
                                            insertInto: managedObjectContext)
        sTrainMember1.setValue(sTrain, forKey: "train")
        sTrainMember1.setValue("One", forKey: "numberOrName")
        sTrainMember1.setValue(0, forKey: "index")

        let sTrainMember2 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["TrainMember"]!,
                                            insertInto: managedObjectContext)
        sTrainMember2.setValue(sTrain, forKey: "train")
        sTrainMember2.setValue("Two", forKey: "numberOrName")
        sTrainMember2.setValue(1, forKey: "index")

        try managedObjectContext.save()
        try performMigration()

        let dTrainsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Train")
        let dTrains = try managedObjectContext.fetch(dTrainsFetchRequest)
        XCTAssertEqual(dTrains.count, 1, "Expected Train after migration")

        let dTrain = dTrains.first!
        let dTrainMembers = try XCTUnwrap(dTrain.value(forKey: "members") as! Set<NSManagedObject>?)
        XCTAssertEqual(dTrainMembers.count, 2, "Expected TrainMember in Train")

        let sortedTrainMembers = dTrainMembers.sorted {
            ($0.value(forKey: "index") as! Int16) < ($1.value(forKey: "index") as! Int16)
        }

        XCTAssertEqual(sortedTrainMembers[0].value(forKey: "numberOrName") as! String?, "One",
                       "Train.members in incorrect order")
        XCTAssertEqual(sortedTrainMembers[0].value(forKey: "index") as! Int16, 0,
                       "TrainMember.index has incorrect value")

        XCTAssertEqual(sortedTrainMembers[1].value(forKey: "numberOrName") as! String?, "Two",
                       "Train.members in incorrect order")
        XCTAssertEqual(sortedTrainMembers[1].value(forKey: "index") as! Int16, 1,
                       "TrainMember.index has incorrect value")

        XCTAssertEqual(dTrain.value(forKey: "maxMemberIndex") as! Int16, 1,
                       "Train.maxMemberIndex not correctly calculated")
    }

    // MARK: TrainMemberToTrainMember

    /// Check that expected fields are copied.
    func testTrainMemberToTrainMember() throws {
        let sTrain = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Train"]!,
                                        insertInto: managedObjectContext)

        let sTrainMember = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["TrainMember"]!,
                                        insertInto: managedObjectContext)
        sTrainMember.setValue(sTrain, forKey: "train")
        sTrainMember.setValue("GWR Hall", forKey: "modelClass")
        sTrainMember.setValue("Hogwarts Castle", forKey: "numberOrName")
        sTrainMember.setValue("Hogwarts Express Livery", forKey: "details")
        sTrainMember.setValue("Not a Castle", forKey: "notes")
        sTrainMember.setValue(true, forKey: "isFlipped")

        try managedObjectContext.save()
        try performMigration()

        let dTrainMembersFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TrainMember")
        let dTrainMembers = try managedObjectContext.fetch(dTrainMembersFetchRequest)
        XCTAssertEqual(dTrainMembers.count, 1, "Expected TrainMember after migration")

        let dTrainMember = dTrainMembers.first!
        XCTAssertNotNil(dTrainMember.value(forKey: "train"),
                        "TrainMember.train not copied from source")
        XCTAssertEqual(dTrainMember.value(forKey: "modelClass") as! String?, "GWR Hall",
                       "TrainMember.modelClass not copied from source")
        XCTAssertEqual(dTrainMember.value(forKey: "numberOrName") as! String?, "Hogwarts Castle",
                       "TrainMember.numberOrName not copied from source")
        XCTAssertEqual(dTrainMember.value(forKey: "details") as! String?, "Hogwarts Express Livery",
                       "TrainMember.details not copied from source")
        XCTAssertEqual(dTrainMember.value(forKey: "notes") as! String?, "Not a Castle",
                       "TrainMember.notes not copied from source")
        XCTAssertEqual(dTrainMember.value(forKey: "flipped") as! Bool, true,
                       "TrainMemberisFlipped not copied from source")
    }

    /// Check that nil string fields are converted to an empty string.
    func testTrainMemberNilEmptyString() throws {
        let sTrain = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Train"]!,
                                        insertInto: managedObjectContext)

        let sTrainMember = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["TrainMember"]!,
                                        insertInto: managedObjectContext)
        sTrainMember.setValue(sTrain, forKey: "train")

        try managedObjectContext.save()
        try performMigration()

        let dTrainMembersFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TrainMember")
        let dTrainMembers = try managedObjectContext.fetch(dTrainMembersFetchRequest)
        XCTAssertEqual(dTrainMembers.count, 1, "Expected TrainMember after migration")

        let dTrainMember = dTrainMembers.first!
        XCTAssertEqual(dTrainMember.value(forKey: "modelClass") as! String?, "",
                       "TrainMember.modelClass not converted to empty string")
        XCTAssertEqual(dTrainMember.value(forKey: "numberOrName") as! String?, "",
                       "TrainMember.numberOrName not converted to empty string")
        XCTAssertEqual(dTrainMember.value(forKey: "details") as! String?, "",
                       "TrainMember.details not converted to empty string")
        XCTAssertEqual(dTrainMember.value(forKey: "notes") as! String?, "",
                       "TrainMember.notes not converted to empty string")
    }

    // MARK: Socket

    /// Check that a Socket entity is created from a Model socket.
    func testModelSocket() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")

        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(1, forKey: "classificationRawValue")
        sModel.setValue("PluX22", forKey: "socket")

        try managedObjectContext.save()
        try performMigration()

        let dModelsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Model")
        let dModels = try managedObjectContext.fetch(dModelsFetchRequest)
        XCTAssertEqual(dModels.count, 1, "Expected Model after migration")

        let dSocket = dModels[0].value(forKey: "socket") as! NSManagedObject?
        XCTAssertNotNil(dSocket, "Socket not created from Model")

        XCTAssertEqual(dSocket!.value(forKey: "title") as! String?, "PluX22",
                       "Socket.title not copied from source Model.socket")
    }

    /// Check that a Socket entity is created from a DecoderType socket.
    func testDecoderTypeSocket() throws {
        let sDecoderType = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                           insertInto: managedObjectContext)
        sDecoderType.setValue("ESU", forKey: "manufacturer")
        sDecoderType.setValue("50123", forKey: "productCode")
        sDecoderType.setValue("PluX22", forKey: "socket")

        try managedObjectContext.save()
        try performMigration()

        let dDecoderTypesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DecoderType")
        let dDecoderTypes = try managedObjectContext.fetch(dDecoderTypesFetchRequest)
        XCTAssertEqual(dDecoderTypes.count, 1, "Expected DecoderType after migration")

        let dDecoderType = dDecoderTypes.first!
        let dSocket = dDecoderType.value(forKey: "socket") as! NSManagedObject?
        XCTAssertNotNil(dSocket, "Socket not created from DecoderType")

        XCTAssertEqual(dSocket?.value(forKey: "title") as! String?, "PluX22",
                       "Socket.title not copied from source DecoderType.socket")
    }

    /// Check that a Socket entities are re-used for multiple Models.
    func testModelSocketReused() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")

        let sModel1 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel1.setValue(sPurchase, forKey: "purchase")
        sModel1.setValue(1, forKey: "classificationRawValue")
        sModel1.setValue("PluX22", forKey: "socket")

        let sModel2 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel2.setValue(sPurchase, forKey: "purchase")
        sModel2.setValue(1, forKey: "classificationRawValue")
        sModel2.setValue("PluX22", forKey: "socket")

        try managedObjectContext.save()
        try performMigration()

        let dModelsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Model")
        let dModels = try managedObjectContext.fetch(dModelsFetchRequest)
        XCTAssertEqual(dModels.count, 2, "Expected Model after migration")

        let dSocket = dModels[0].value(forKey: "socket") as! NSManagedObject?
        XCTAssertNotNil(dSocket, "Socket not created from Model")

        XCTAssertEqual(dModels[1].value(forKey: "socket") as! NSManagedObject?, dSocket,
                       "Socket not re-used from previous Model")
    }

    /// Check that a Socket entities with different names are not re-used for multiple Models.
    func testModelSocketNotReused() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")

        let sModel1 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel1.setValue(sPurchase, forKey: "purchase")
        sModel1.setValue(1, forKey: "classificationRawValue")
        sModel1.setValue("PluX22", forKey: "socket")

        let sModel2 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel2.setValue(sPurchase, forKey: "purchase")
        sModel2.setValue(1, forKey: "classificationRawValue")
        sModel2.setValue("21MTC", forKey: "socket")

        try managedObjectContext.save()
        try performMigration()

        let dModelsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Model")
        let dModels = try managedObjectContext.fetch(dModelsFetchRequest)
        XCTAssertEqual(dModels.count, 2, "Expected Model after migration")

        let dSocket = dModels[0].value(forKey: "socket") as! NSManagedObject?
        XCTAssertNotNil(dSocket, "Socket not created from Model")

        XCTAssertNotEqual(dModels[1].value(forKey: "socket") as! NSManagedObject?, dSocket,
                          "Socket incorrectly re-used from previous Model")
    }

    /// Check that a Socket entities are re-used for multiple DecoderTypes.
    func testDecoderTypeSocketReused() throws {
        let sDecoderType1 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                           insertInto: managedObjectContext)
        sDecoderType1.setValue("ESU", forKey: "manufacturer")
        sDecoderType1.setValue("50123", forKey: "productCode")
        sDecoderType1.setValue("PluX22", forKey: "socket")

        let sDecoderType2 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                           insertInto: managedObjectContext)
        sDecoderType2.setValue("ESU", forKey: "manufacturer")
        sDecoderType2.setValue("50456", forKey: "productCode")
        sDecoderType2.setValue("PluX22", forKey: "socket")

        try managedObjectContext.save()
        try performMigration()

        let dDecoderTypesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DecoderType")
        let dDecoderTypes = try managedObjectContext.fetch(dDecoderTypesFetchRequest)
        XCTAssertEqual(dDecoderTypes.count, 2, "Expected DecoderType after migration")

        let dSocket = dDecoderTypes[0].value(forKey: "socket") as! NSManagedObject?
        XCTAssertNotNil(dSocket, "Socket not created from DecoderType")

        XCTAssertEqual(dDecoderTypes[1].value(forKey: "socket") as! NSManagedObject?, dSocket,
                       "Socket not re-used from previous DecoderType")
    }

    /// Check that a Socket entities with different names are not re-used for multiple DecoderTypes.
    func testDecoderTypeSocketNotReused() throws {
        let sDecoderType1 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                           insertInto: managedObjectContext)
        sDecoderType1.setValue("ESU", forKey: "manufacturer")
        sDecoderType1.setValue("50123", forKey: "productCode")
        sDecoderType1.setValue("PluX22", forKey: "socket")

        let sDecoderType2 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                           insertInto: managedObjectContext)
        sDecoderType2.setValue("ESU", forKey: "manufacturer")
        sDecoderType2.setValue("50456", forKey: "productCode")
        sDecoderType2.setValue("21MTC", forKey: "socket")

        try managedObjectContext.save()
        try performMigration()

        let dDecoderTypesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DecoderType")
        let dDecoderTypes = try managedObjectContext.fetch(dDecoderTypesFetchRequest)
        XCTAssertEqual(dDecoderTypes.count, 2, "Expected DecoderType after migration")

        let dSocket = dDecoderTypes[0].value(forKey: "socket") as! NSManagedObject?
        XCTAssertNotNil(dSocket, "Socket not created from DecoderType")

        XCTAssertNotEqual(dDecoderTypes[1].value(forKey: "socket") as! NSManagedObject?, dSocket,
                          "Socket incorrectly re-used from previous DecoderType")
    }

    /// Check that Socket entities are re-used between Model and DecoderTypes.
    func testModelDecoderTypeSocketReused() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")

        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(1, forKey: "classificationRawValue")
        sModel.setValue("PluX22", forKey: "socket")

        let sDecoderType = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                           insertInto: managedObjectContext)
        sDecoderType.setValue("ESU", forKey: "manufacturer")
        sDecoderType.setValue("50123", forKey: "productCode")
        sDecoderType.setValue("PluX22", forKey: "socket")

        try managedObjectContext.save()
        try performMigration()

        let dModelsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Model")
        let dModels = try managedObjectContext.fetch(dModelsFetchRequest)
        XCTAssertEqual(dModels.count, 1, "Expected Model after migration")

        let dSocket = dModels[0].value(forKey: "socket") as! NSManagedObject?
        XCTAssertNotNil(dSocket, "Socket not created from Model")

        let dDecoderTypesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DecoderType")
        let dDecoderTypes = try managedObjectContext.fetch(dDecoderTypesFetchRequest)
        XCTAssertEqual(dDecoderTypes.count, 1, "Expected DecoderType after migration")

        XCTAssertEqual(dDecoderTypes[0].value(forKey: "socket") as! NSManagedObject?, dSocket,
                       "Socket not re-used from previous DecoderType")
    }

    /// Check that numberOfPins is set correctly.
    func testSocketNumberOfPins() throws {
        let socketPinsMap = [
            ("4-pin NEM654", 4),
            ("6-pin NEM651", 6),
            ("8-pin NEM652", 8),
            ("PluX8", 8),
            ("PluX16", 16),
            ("Next18", 18),
            ("Next18-S", 18),
            ("21MTC", 21),
            ("PluX22", 22),
        ]

        for (socket, _) in socketPinsMap {
            let sDecoderType = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                               insertInto: managedObjectContext)
            sDecoderType.setValue("ESU", forKey: "manufacturer")
            sDecoderType.setValue("50123", forKey: "productCode")
            sDecoderType.setValue(socket, forKey: "socket")
        }

        try managedObjectContext.save()
        try performMigration()

        for (socket, numberOfPins) in socketPinsMap {
            let dSocketsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Socket")
            dSocketsFetchRequest.predicate = NSPredicate(format: "title = %@", socket)
            let dSockets = try managedObjectContext.fetch(dSocketsFetchRequest)
            XCTAssertEqual(dSockets.count, 1, "Expected Socket after migration")

            let dSocket = dSockets.first!
            XCTAssertEqual(dSocket.value(forKey: "numberOfPins") as! Int16, Int16(numberOfPins),
                           "Socket.numberOfPins not correctly calcluated")
        }
    }

    // MARK: Speaker

    /// Check that a Speaker entity is created from a Model speaker.
    func testModelSpeaker() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")

        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(1, forKey: "classificationRawValue")
        sModel.setValue("2W Bass Reflex", forKey: "speaker")

        try managedObjectContext.save()
        try performMigration()

        let dModelsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Model")
        let dModels = try managedObjectContext.fetch(dModelsFetchRequest)
        XCTAssertEqual(dModels.count, 1, "Expected Model after migration")

        let dSpeakers = try XCTUnwrap(dModels[0].value(forKey: "speakers") as! Set<NSManagedObject>?)
        XCTAssertEqual(dSpeakers.count, 1, "Expected Speaker in Model")

        let dSpeaker = dSpeakers[dSpeakers.startIndex]
        XCTAssertEqual(dSpeaker.value(forKey: "title") as! String?, "2W Bass Reflex",
                       "Speaker.title not copied from source Model.speaker")

        // Sanity check record counts.
        let dSpeakersFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Speaker")
        let dAllSpeakers = try managedObjectContext.fetch(dSpeakersFetchRequest)
        XCTAssertEqual(dAllSpeakers.count, dSpeakers.count, "Mis-matched SpeakerFitting count after migration")
    }

    /// Check that SpeakerFittings are migrated from Model to Speaker.
    func testModelSpeakerFittings() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")

        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(1, forKey: "classificationRawValue")
        sModel.setValue("2W Bass Reflex", forKey: "speaker")

        let sFitting1 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["SpeakerFitting"]!,
                                     insertInto: managedObjectContext)
        sFitting1.setValue(sModel, forKey: "model")
        sFitting1.setValue("PCB Soldered", forKey: "title")

        let sFitting2 = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["SpeakerFitting"]!,
                                     insertInto: managedObjectContext)
        sFitting2.setValue(sModel, forKey: "model")
        sFitting2.setValue("Enclosed", forKey: "title")

        try managedObjectContext.save()
        try performMigration()

        let dModelsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Model")
        let dModels = try managedObjectContext.fetch(dModelsFetchRequest)
        XCTAssertEqual(dModels.count, 1, "Expected Model after migration")

        let dSpeakers = try XCTUnwrap(dModels[0].value(forKey: "speakers") as! Set<NSManagedObject>?)
        XCTAssertEqual(dSpeakers.count, 1, "Expected Speaker in Model")

        let dSpeaker = dSpeakers[dSpeakers.startIndex]
        let dSpeakerFittings = try XCTUnwrap(dSpeaker.value(forKey: "fittings") as! Set<NSManagedObject>?)
        XCTAssertEqual(dSpeakerFittings.count, 2, "Expected SpeakerFitting in Speaker")

        let sortedSpeakerFittings = dSpeakerFittings.sorted {
            ($0.value(forKey: "title") as! String) < ($1.value(forKey: "title") as! String)
        }

        XCTAssertEqual(sortedSpeakerFittings[0].value(forKey: "title") as! String?, "Enclosed",
                       "SpeakerFitting.title not copied from source")
        XCTAssertEqual(sortedSpeakerFittings[1].value(forKey: "title") as! String?, "PCB Soldered",
                       "SpeakerFitting.title not copied from source")

        // Sanity check none left over
        let dSpeakerFittingsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SpeakerFitting")
        let dAllSpeakerFittings = try managedObjectContext.fetch(dSpeakerFittingsFetchRequest)
        XCTAssertEqual(dAllSpeakerFittings.count, dSpeakerFittings.count, "Mis-matched SpeakerFitting count after migration")
    }

    /// Check that a Speaker entity is not created when theModel speaker is empty.
    func testModelSpeakerEmpty() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")

        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(1, forKey: "classificationRawValue")

        try managedObjectContext.save()
        try performMigration()

        let dModelsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Model")
        let dModels = try managedObjectContext.fetch(dModelsFetchRequest)
        XCTAssertEqual(dModels.count, 1, "Expected Model after migration")

        let dSpeakers = try XCTUnwrap(dModels[0].value(forKey: "speakers") as! Set<NSManagedObject>?)
        XCTAssertEqual(dSpeakers.count, 0, "Unexpected Speaker in purchase")

        // Sanity check record counts.
        let dSpeakersFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Speaker")
        let dAllSpeakers = try managedObjectContext.fetch(dSpeakersFetchRequest)
        XCTAssertEqual(dAllSpeakers.count, dSpeakers.count, "Mis-matched SpeakerFitting count after migration")
    }

}
