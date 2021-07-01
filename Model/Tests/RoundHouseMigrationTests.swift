//
//  RoundHouseMigrationTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import XCTest
import CoreData

@testable import RoundHouse

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
        sPurchase.setValue(Purchase.Condition.likeNew.rawValue, forKey: "conditionRawValue")
        sPurchase.setValue(NSDecimalNumber(value: 100), forKey: "valuation")
        sPurchase.setValue("Test", forKey: "notes")
        
        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        XCTAssertEqual(dPurchase.value(forKey: "manufacturer") as! String?, "Hornby",
                       "manufacturer not copied from source Purchase")
        XCTAssertEqual(dPurchase.value(forKey: "catalogNumber") as! String?, "R1234",
                       "catalogNumber not copied from source Purchase")
        XCTAssertEqual(dPurchase.value(forKey: "catalogDescription") as! String?, "Express Train",
                       "catalogDescription not copied from source Purchase")
        XCTAssertEqual(dPurchase.value(forKey: "catalogYear") as! Int16, 2000,
                       "catalogYear not copied from source Purchase")
        XCTAssertEqual(dPurchase.value(forKey: "limitedEdition") as! String?, "Limited Edition",
                       "limitedEdition not copied from source Purchase")
        XCTAssertEqual(dPurchase.value(forKey: "limitedEditionNumber") as! Int16, 25,
                       "limitedEditionNumber not copied from source Purchase")
        XCTAssertEqual(dPurchase.value(forKey: "limitedEditionCount") as! Int16, 500,
                       "limitedEditionCount not copied from source Purchase")
        XCTAssertEqual(dPurchase.value(forKey: "dateComponents") as! DateComponents?,
                       DateComponents(year: 2010, month: 12, day: 25),
                       "dateComponents not copied from source Purchase")
        XCTAssertEqual(dPurchase.value(forKey: "store") as! String?, "Hattons",
                       "store not copied from source Purchase")
        XCTAssertEqual(dPurchase.value(forKey: "priceRawValue") as! NSDecimalNumber?,
                       NSDecimalNumber(value: 129.99),
                       "priceRawValue not copied from source Purchase")
        XCTAssertEqual(dPurchase.value(forKey: "conditionRawValue") as! Int16,
                       Purchase.Condition.likeNew.rawValue,
                       "conditionRawValue not copied from source Purchase")
        XCTAssertEqual(dPurchase.value(forKey: "valuationRawValue") as! NSDecimalNumber?,
                       NSDecimalNumber(value: 100),
                       "valuationRawValue not copied from source Purchase")
        XCTAssertEqual(dPurchase.value(forKey: "notes") as! String?, "Test",
                       "notes not copied from source Purchase")
    }

    /// Check that nil string fields are converted to an empty string.
    func testPurchaseNilEmptyString() throws {
        let _ = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                insertInto: managedObjectContext)
        
        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        XCTAssertEqual(dPurchase.value(forKey: "manufacturer") as! String?, "",
                       "manufacturer not converted to empty string")
        XCTAssertEqual(dPurchase.value(forKey: "catalogNumber") as! String?, "",
                       "catalogNumber not converted to empty string")
        XCTAssertEqual(dPurchase.value(forKey: "catalogDescription") as! String?, "",
                       "catalogDescription not converted to empty string")
        XCTAssertEqual(dPurchase.value(forKey: "limitedEdition") as! String?, "",
                       "limitedEdition not converted to empty string")
        XCTAssertEqual(dPurchase.value(forKey: "store") as! String?, "",
                       "store not converted to empty string")
        XCTAssertEqual(dPurchase.value(forKey: "notes") as! String?, "",
                       "notes not converted to empty string")
    }
    
    /// Check that the en_GB locale code is converted to a GBP currency code.
    func testPriceCurrencyGBP() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("en_GB", forKey: "priceCurrency")
        
        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        XCTAssertEqual(dPurchase.value(forKey: "priceCurrencyCode") as! String?, "GBP",
                       "priceCurrency not correctly converted")

    }

    /// Check that the en_US locale code is converted to a USD currency code.
    func testPriceCurrencyUSD() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("en_US", forKey: "priceCurrency")
        
        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        XCTAssertEqual(dPurchase.value(forKey: "priceCurrencyCode") as! String?, "USD",
                       "priceCurrency not correctly converted")

    }

    /// Check that the en_GB locale code is converted to a GBP currency code.
    func testValuationCurrencyGBP() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("en_GB", forKey: "valuationCurrency")
        
        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        XCTAssertEqual(dPurchase.value(forKey: "valuationCurrencyCode") as! String?, "GBP",
                       "valuationCurrency not correctly converted")

    }

    /// Check that the en_US locale code is converted to a USD currency code.
    func testValuationCurrencyUSD() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("en_US", forKey: "valuationCurrency")
        
        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        XCTAssertEqual(dPurchase.value(forKey: "valuationCurrencyCode") as! String?, "USD",
                       "valuationCurrency not correctly converted")

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
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 2, "Expected models in purchase")
        
        let sortedModels = dModels.sorted {
            ($0.value(forKey: "index") as! Int16) < ($1.value(forKey: "index") as! Int16)
        }

        XCTAssertEqual(sortedModels[0].value(forKey: "modelClass") as! String?, "One",
                       "models in incorrect order")
        XCTAssertEqual(sortedModels[0].value(forKey: "index") as! Int16, 0,
                       "Model has incorrect index")

        XCTAssertEqual(sortedModels[1].value(forKey: "modelClass") as! String?, "Two",
                       "models in incorrect order")
        XCTAssertEqual(sortedModels[1].value(forKey: "index") as! Int16, 1,
                       "Model has incorrect index")

        XCTAssertEqual(dPurchase.value(forKey: "maxModelIndex") as! Int16, 1,
                       "maxModelIndex not correctly calculated")
        
        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 0, "Unexpected accessories in purchase")

        XCTAssertEqual(dPurchase.value(forKey: "maxAccessoryIndex") as! Int16, -1,
                       "maxAccessoryIndex not correctly calculated")
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
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 0, "Unexpected models in purchase")
        
        XCTAssertEqual(dPurchase.value(forKey: "maxModelIndex") as! Int16, -1,
                       "maxModelIndex not correctly calculated")
        
        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 2, "Expected accessories in purchase")

        let sortedAccessories = dAccessories.sorted {
            ($0.value(forKey: "index") as! Int16) < ($1.value(forKey: "index") as! Int16)
        }

        XCTAssertEqual(sortedAccessories[0].value(forKey: "catalogDescription") as! String?, "One",
                       "accessories in incorrect order")
        XCTAssertEqual(sortedAccessories[0].value(forKey: "index") as! Int16, 0,
                       "Accessory has incorrect index")

        XCTAssertEqual(sortedAccessories[1].value(forKey: "catalogDescription") as! String?, "Two",
                       "accessories in incorrect order")
        XCTAssertEqual(sortedAccessories[1].value(forKey: "index") as! Int16, 1,
                       "Accessory has incorrect index")

        XCTAssertEqual(dPurchase.value(forKey: "maxAccessoryIndex") as! Int16, 1,
                       "maxAccessoryIndex not correctly calculated")
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
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 2, "Expected models in purchase")
        
        let sortedModels = dModels.sorted {
            ($0.value(forKey: "index") as! Int16) < ($1.value(forKey: "index") as! Int16)
        }

        XCTAssertEqual(sortedModels[0].value(forKey: "modelClass") as! String?, "One",
                       "models in incorrect order")
        XCTAssertEqual(sortedModels[0].value(forKey: "index") as! Int16, 0,
                       "Model has incorrect index")

        XCTAssertEqual(sortedModels[1].value(forKey: "modelClass") as! String?, "Three",
                       "models in incorrect order")
        XCTAssertEqual(sortedModels[1].value(forKey: "index") as! Int16, 1,
                       "Model has incorrect index")

        XCTAssertEqual(dPurchase.value(forKey: "maxModelIndex") as! Int16, 1,
                       "maxModelIndex not correctly calculated")

        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 2, "Expected accessories in purchase")

        let sortedAccessories = dAccessories.sorted {
            ($0.value(forKey: "index") as! Int16) < ($1.value(forKey: "index") as! Int16)
        }

        XCTAssertEqual(sortedAccessories[0].value(forKey: "catalogDescription") as! String?, "Two",
                       "accessories in incorrect order")
        XCTAssertEqual(sortedAccessories[0].value(forKey: "index") as! Int16, 0,
                       "Accessory has incorrect index")

        XCTAssertEqual(sortedAccessories[1].value(forKey: "catalogDescription") as! String?, "Four",
                       "accessories in incorrect order")
        XCTAssertEqual(sortedAccessories[1].value(forKey: "index") as! Int16, 1,
                       "Accessory has incorrect index")

        XCTAssertEqual(dPurchase.value(forKey: "maxAccessoryIndex") as! Int16, 1,
                       "maxAccessoryIndex not correctly calculated")
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
        sModel.setValue(Model.Era.currentEra.rawValue, forKey: "eraRawValue")
        sModel.setValue(Model.Disposition.collectorItem.rawValue, forKey: "dispositionRawValue")
        sModel.setValue("5-pole", forKey: "motor")
        sModel.setValue("2W Bass Reflex", forKey: "speaker")
        sModel.setValue(DateComponents(year: 2020, month: 6, day: 17), forKey: "lastOil")
        sModel.setValue(DateComponents(year: 2020, month: 6, day: 19), forKey: "lastRun")
        sModel.setValue("Test", forKey: "notes")

        try managedObjectContext.save()
        try performMigration()

        let dModelsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Model")
        let dModels = try managedObjectContext.fetch(dModelsFetchRequest)
        XCTAssertEqual(dModels.count, 1, "Expected models after migration")

        let dModel = dModels.first!
        XCTAssertNotNil(dModel.value(forKey: "purchase"),
                        "purchase not set from source Model")
        XCTAssertEqual(dModel.value(forKey: "imageData") as! Data?,
                       "test".data(using: .utf8),
                       "imageData not copied from source Model")
        XCTAssertEqual(dModel.value(forKey: "modelClass") as! String?, "LNER A4",
                       "modelClass not copied from source Model")
        XCTAssertEqual(dModel.value(forKey: "wheelArrangement") as! String?, "4-6-2",
                       "wheelArrangement not copied from source Model")
        XCTAssertEqual(dModel.value(forKey: "gauge") as! String?, "HO",
                       "gauge not copied from source Model")
        XCTAssertEqual(dModel.value(forKey: "name") as! String?, "Boris Johnson",
                       "name not copied from source Model")
        XCTAssertEqual(dModel.value(forKey: "number") as! String?, "4600",
                       "number not copied from source Model")
        XCTAssertEqual(dModel.value(forKey: "livery") as! String?, "BR Blue",
                       "livery not copied from source Model")
        XCTAssertEqual(dModel.value(forKey: "details") as! String?, "Great British Railways",
                       "details not copied from source Model")
        XCTAssertEqual(dModel.value(forKey: "eraRawValue") as! Int16,
                       Model.Era.currentEra.rawValue,
                       "eraRawValue not copied from source Model")
        XCTAssertEqual(dModel.value(forKey: "dispositionRawValue") as! Int16,
                       Model.Disposition.collectorItem.rawValue,
                       "dispositionRawValue not copied from source Model")
        XCTAssertEqual(dModel.value(forKey: "motor") as! String?, "5-pole",
                       "motor not copied from source Model")
        XCTAssertEqual(dModel.value(forKey: "speaker") as! String?, "2W Bass Reflex",
                       "speaker not copied from source Model")
        XCTAssertEqual(dModel.value(forKey: "lastOilDateComponents") as! DateComponents?,
                       DateComponents(year: 2020, month: 6, day: 17),
                       "lastOilDateComponents not copied from source Model")
        XCTAssertEqual(dModel.value(forKey: "lastRunDateComponents") as! DateComponents?,
                       DateComponents(year: 2020, month: 6, day: 19),
                       "lastRunDateComponents not copied from source Model")
        XCTAssertEqual(dModel.value(forKey: "notes") as! String?, "Test",
                       "notes not copied from source Model")
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
        XCTAssertEqual(dModels.count, 1, "Expected models after migration")

        let dModel = dModels.first!
        XCTAssertEqual(dModel.value(forKey: "modelClass") as! String?, "",
                       "modelClass not converted to empty string")
        XCTAssertEqual(dModel.value(forKey: "wheelArrangement") as! String?, "",
                       "wheelArrangement not converted to empty string")
        // Gauge is defaulted to "OO" so will never be nil.
        XCTAssertEqual(dModel.value(forKey: "name") as! String?, "",
                       "name not converted to empty string")
        XCTAssertEqual(dModel.value(forKey: "number") as! String?, "",
                       "number not converted to empty string")
        XCTAssertEqual(dModel.value(forKey: "livery") as! String?, "",
                       "livery not converted to empty string")
        XCTAssertEqual(dModel.value(forKey: "details") as! String?, "",
                       "details not converted to empty string")
        XCTAssertEqual(dModel.value(forKey: "motor") as! String?, "",
                       "motor not converted to empty string")
        XCTAssertEqual(dModel.value(forKey: "speaker") as! String?, "",
                       "speaker not converted to empty string")
        XCTAssertEqual(dModel.value(forKey: "notes") as! String?, "",
                       "notes not converted to empty string")
    }
    
    /// Check that classification for diesel and electric locomotives remains the same.
    func testClassificationDieselElectricLocomotive() throws {
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

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 1, "Expected models in purchase")
        
        let dModel = dModels[dModels.startIndex]
        XCTAssertEqual(dModel.value(forKey: "classificationRawValue") as! Int16, Model.Classification.dieselElectricLocomotive.rawValue,
                       "classificationRawValue not copied from source Model")
    }

    /// Check that classification for steam locomotives is renumbered.
    func testClassificationSteamLocomotive() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")
        
        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(9, forKey: "classificationRawValue")
        
        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 1, "Expected models in purchase")
        
        let dModel = dModels[dModels.startIndex]
        XCTAssertEqual(dModel.value(forKey: "classificationRawValue") as! Int16, Model.Classification.steamLocomotive.rawValue,
                       "classificationRawValue not converted from source Model")
    }

    /// Check that classification for coaches is renumbered.
    func testClassificationCoach() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")
        
        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(2, forKey: "classificationRawValue")
        
        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 1, "Expected models in purchase")
        
        let dModel = dModels[dModels.startIndex]
        XCTAssertEqual(dModel.value(forKey: "classificationRawValue") as! Int16, Model.Classification.coach.rawValue,
                       "classificationRawValue not converted from source Model")
    }

    /// Check that classification for wagons is renumbered.
    func testClassificationWagon() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")
        
        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(3, forKey: "classificationRawValue")
        
        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 1, "Expected models in purchase")
        
        let dModel = dModels[dModels.startIndex]
        XCTAssertEqual(dModel.value(forKey: "classificationRawValue") as! Int16, Model.Classification.wagon.rawValue,
                       "classificationRawValue not converted from source Model")
    }

    /// Check that classification for multiple unites is renumbered.
    func testClassificationMultipleUnit() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")
        
        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(4, forKey: "classificationRawValue")
        
        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 1, "Expected models in purchase")
        
        let dModel = dModels[dModels.startIndex]
        XCTAssertEqual(dModel.value(forKey: "classificationRawValue") as! Int16, Model.Classification.multipleUnit.rawValue,
                       "classificationRawValue not converted from source Model")
    }

    /// Check that classification for departmentals is renumbered.
    func testClassificationDepartmental() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")
        
        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(5, forKey: "classificationRawValue")
        
        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 1, "Expected models in purchase")
        
        let dModel = dModels[dModels.startIndex]
        XCTAssertEqual(dModel.value(forKey: "classificationRawValue") as! Int16, Model.Classification.departmental.rawValue,
                       "classificationRawValue not converted from source Model")
    }

    /// Check that classification for models with no protoype is renumbered.
    func testClassificationNoPrototype() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")
        
        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(6, forKey: "classificationRawValue")
        
        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 1, "Expected models in purchase")
        
        let dModel = dModels[dModels.startIndex]
        XCTAssertEqual(dModel.value(forKey: "classificationRawValue") as! Int16, Model.Classification.noPrototype.rawValue,
                       "classificationRawValue not converted from source Model")
    }

    /// Check that classification for vehicles is renumbered.
    func testClassificationVehicle() throws {
        let sPurchase = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Purchase"]!,
                                        insertInto: managedObjectContext)
        sPurchase.setValue("Hornby", forKey: "manufacturer")
        sPurchase.setValue("R1234", forKey: "catalogNumber")
        
        let sModel = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["Model"]!,
                                     insertInto: managedObjectContext)
        sModel.setValue(sPurchase, forKey: "purchase")
        sModel.setValue(8, forKey: "classificationRawValue")
        
        try managedObjectContext.save()
        try performMigration()

        let dPurchasesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Purchase")
        let dPurchases = try managedObjectContext.fetch(dPurchasesFetchRequest)
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 1, "Expected models in purchase")
        
        let dModel = dModels[dModels.startIndex]
        XCTAssertEqual(dModel.value(forKey: "classificationRawValue") as! Int16, Model.Classification.vehicle.rawValue,
                       "classificationRawValue not converted from source Model")
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
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        let dModels = try XCTUnwrap(dPurchase.value(forKey: "models") as! Set<NSManagedObject>?)
        XCTAssertEqual(dModels.count, 0, "Unexpected models in purchase, should have been converted to accessory")

        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 1, "Expected accessories in purchase")

        let dAccessory = dAccessories[dAccessories.startIndex]
        XCTAssertEqual(dAccessory.value(forKey: "purchase") as! NSManagedObject?, dPurchase,
                       "purchase not copied from source Model")
        XCTAssertEqual(dAccessory.value(forKey: "manufacturer") as! String?, "Hornby",
                       "manufacturer not copied from source Purchase")
        XCTAssertEqual(dAccessory.value(forKey: "catalogNumber") as! String?, "",
                       "catalogDescription not set to empty string")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "Straight Track",
                       "catalogDescription not copied from source Model.modelClass")
        XCTAssertEqual(dAccessory.value(forKey: "imageData") as! Data?, "Test".data(using: .utf8),
                       "imageData not copied from source Model")
        XCTAssertEqual(dAccessory.value(forKey: "gauge") as! String?, "HO",
                       "gauge not copied from source Model")
        XCTAssertEqual(dAccessory.value(forKey: "notes") as! String?, "Some Notes",
                       "notes not copied from source Model")
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
        XCTAssertEqual(dAccessories.count, 1, "Expected accessories after migration")
        
        let dAccessory = dAccessories.first!
        XCTAssertEqual(dAccessory.value(forKey: "manufacturer") as! String?, "",
                       "manufacturer not converted from empty string")
        XCTAssertEqual(dAccessory.value(forKey: "catalogNumber") as! String?, "",
                       "catalogNumber not converted from empty string")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "",
                       "catalogDescription not converted from empty string")
        XCTAssertEqual(dAccessory.value(forKey: "notes") as! String?, "",
                       "notes not converted from empty string")
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
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 1, "Expected accessories in purchase")

        let dAccessory = dAccessories[dAccessories.startIndex]
        XCTAssertEqual(dAccessory.value(forKey: "catalogNumber") as! String?, "R600",
                       "catalogNumber not extracted from source Model.modelClass")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "Straight Track",
                       "catalogDescription not extracted from source Model.modelClass")
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
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 1, "Expected accessories in purchase")

        let dAccessory = dAccessories[dAccessories.startIndex]
        XCTAssertEqual(dAccessory.value(forKey: "catalogNumber") as! String?, "36-420",
                       "catalogNumber not extracted from source Model.modelClass")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "Midland Pullman Stewards & Train Crew",
                       "catalogDescription not extracted from source Model.modelClass")
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
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 1, "Expected accessories in purchase")

        let dAccessory = dAccessories[dAccessories.startIndex]
        XCTAssertEqual(dAccessory.value(forKey: "catalogNumber") as! String?, "SL-E180",
                       "catalogNumber not extracted from source Model.modelClass")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "Single Slip (Code 75)",
                       "catalogDescription not extracted from source Model.modelClass")
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
        XCTAssertEqual(dPurchases.count, 1, "Expected purchases after migration")
        
        let dPurchase = dPurchases.first!
        let dAccessories = try XCTUnwrap(dPurchase.value(forKey: "accessories") as! Set<NSManagedObject>?)
        XCTAssertEqual(dAccessories.count, 1, "Expected accessories in purchase")

        let dAccessory = dAccessories[dAccessories.startIndex]
        XCTAssertEqual(dAccessory.value(forKey: "catalogNumber") as! String?, "",
                       "catalogNumber unexpectedly extracted from source Model.modelClass")
        XCTAssertEqual(dAccessory.value(forKey: "catalogDescription") as! String?, "45ft Container",
                       "catalogDescription not copied from source Model.modelClass")
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
        XCTAssertEqual(dDecoderTypes.count, 1, "Expected decoder types after migration")
        
        let dDecoderType = dDecoderTypes.first!
        XCTAssertEqual(dDecoderType.value(forKey: "manufacturer") as! String?, "ESU",
                       "manufacturer not copied from source DecoderType")
        XCTAssertEqual(dDecoderType.value(forKey: "catalogNumber") as! String?, "50123",
                       "catalogNumber not copied from source DecoderType")
        XCTAssertEqual(dDecoderType.value(forKey: "catalogFamily") as! String?, "LokSound",
                       "catalogFamily not copied from source DecoderType")
        XCTAssertEqual(dDecoderType.value(forKey: "catalogName") as! String?, "LokSound",
                       "catalogFamily not copied from source DecoderType.productFamily")
        XCTAssertEqual(dDecoderType.value(forKey: "catalogDescription") as! String?, "LokSound PluX22",
                       "catalogDescription not copied from source DecoderType")
        XCTAssertEqual(dDecoderType.value(forKey: "imageData") as! Data?, "Test".data(using: .utf8),
                       "imageData not copied from source DecoderType")
        XCTAssertEqual(dDecoderType.value(forKey: "isProgrammable") as! Bool, true,
                       "isProgrammable not copied from source DecoderType")
        XCTAssertEqual(dDecoderType.value(forKey: "isSoundSupported") as! Bool, true,
                       "isSoundSupported not copied from source DecoderType")
        XCTAssertEqual(dDecoderType.value(forKey: "isRailComSupported") as! Bool, true,
                       "isRailComSupported not copied from source DecoderType")
        XCTAssertEqual(dDecoderType.value(forKey: "minimumStock") as! Int16, 10,
                       "minimumStock not copied from source DecoderType")
    }

    /// Check that nil string fields are converted to an empty string.
    func testDecoderTypeNilEmptyString() throws {
        let _ = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                insertInto: managedObjectContext)
        
        try managedObjectContext.save()
        try performMigration()

        let dDecoderTypesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DecoderType")
        let dDecoderTypes = try managedObjectContext.fetch(dDecoderTypesFetchRequest)
        XCTAssertEqual(dDecoderTypes.count, 1, "Expected decoder types after migration")
        
        let dDecoderType = dDecoderTypes.first!
        XCTAssertEqual(dDecoderType.value(forKey: "manufacturer") as! String?, "",
                       "manufacturer not converted to empty string")
        XCTAssertEqual(dDecoderType.value(forKey: "catalogNumber") as! String?, "",
                       "catalogNumber not converted to empty string")
        XCTAssertEqual(dDecoderType.value(forKey: "catalogName") as! String?, "",
                       "catalogName not converted to empty string")
        XCTAssertEqual(dDecoderType.value(forKey: "catalogFamily") as! String?, "",
                       "catalogFamily not converted to empty string")
        XCTAssertEqual(dDecoderType.value(forKey: "catalogDescription") as! String?, "",
                       "catalogDescription not converted to empty string")
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

        let dDecodersFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Decoder")
        let dDecoders = try managedObjectContext.fetch(dDecodersFetchRequest)
        XCTAssertEqual(dDecoders.count, 1, "Expected decoders after migration")
        
        let dDecoder = dDecoders.first!
        XCTAssertNotNil(dDecoder.value(forKey: "type"),
                        "type not copied from source Decoder")
        XCTAssertEqual(dDecoder.value(forKey: "address") as! Int16, 3,
                       "address not copied from source Decoder")
        XCTAssertEqual(dDecoder.value(forKey: "serialNumber") as! String?, "CAFEF00D",
                       "serialNumber not copied from source Decoder")
        XCTAssertEqual(dDecoder.value(forKey: "firmwareVersion") as! String?, "3.11",
                       "firmwareVersion not copied from source Decoder")
        XCTAssertEqual(dDecoder.value(forKey: "firmwareDateComponents") as! DateComponents?,
                       DateComponents(year: 2019, month: 9, day: 15),
                       "firmwareDateComponents not copied from source Decoder")
        XCTAssertEqual(dDecoder.value(forKey: "soundAuthor") as! String?, "Legomanbiffo",
                       "soundAuthor not copied from source Decoder")
        XCTAssertEqual(dDecoder.value(forKey: "soundProject") as! String?, "A4",
                       "soundProject not copied from source Decoder")
        XCTAssertEqual(dDecoder.value(forKey: "soundProjectVersion") as! String?, "V12",
                       "soundProjectVersion not copied from source Decoder")
        XCTAssertEqual(dDecoder.value(forKey: "soundSettings") as! String?, "CV14.1=0",
                       "soundSettings not copied from source Decoder")
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
        XCTAssertEqual(dDecoders.count, 1, "Expected decoders after migration")
        
        let dDecoder = dDecoders.first!
        XCTAssertEqual(dDecoder.value(forKey: "serialNumber") as! String?, "",
                       "serialNumber not converted to empty string")
        XCTAssertEqual(dDecoder.value(forKey: "firmwareVersion") as! String?, "",
                       "firmwareVersion not converted to empty string")
        XCTAssertEqual(dDecoder.value(forKey: "soundAuthor") as! String?, "",
                       "soundAuthor not converted to empty string")
        XCTAssertEqual(dDecoder.value(forKey: "soundProject") as! String?, "",
                       "soundProject not converted to empty string")
        XCTAssertEqual(dDecoder.value(forKey: "soundProjectVersion") as! String?, "",
                       "soundProjectVersion not converted to empty string")
        XCTAssertEqual(dDecoder.value(forKey: "soundSettings") as! String?, "",
                       "soundSettings not converted to empty string")
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
        XCTAssertEqual(dTrains.count, 1, "Expected trains after migration")
        
        let dTrain = dTrains.first!
        XCTAssertEqual(dTrain.value(forKey: "name") as! String?, "Hogwarts Express",
                       "name not copied from source Train")
        XCTAssertEqual(dTrain.value(forKey: "number") as! String?, "9 3/4",
                       "number not copied from source Train")
        XCTAssertEqual(dTrain.value(forKey: "details") as! String?, "Chamber of Secrets",
                       "details not copied from source Train")
        XCTAssertEqual(dTrain.value(forKey: "trainDescription") as! String?, "Hogwarts Castle and Coaches",
                       "trainDescription not copied from source Train")
        XCTAssertEqual(dTrain.value(forKey: "notes") as! String?, "Test",
                       "notes not copied from source Train")
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
                       "name not converted to empty string")
        XCTAssertEqual(dTrain.value(forKey: "number") as! String?, "",
                       "number not converted to empty string")
        XCTAssertEqual(dTrain.value(forKey: "details") as! String?, "",
                       "details not converted to empty string")
        XCTAssertEqual(dTrain.value(forKey: "trainDescription") as! String?, "",
                       "trainDescription not converted to empty string")
        XCTAssertEqual(dTrain.value(forKey: "notes") as! String?, "",
                       "notes not converted to empty string")
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
        XCTAssertEqual(dTrainMembers.count, 1, "Expected train members after migration")
        
        let dTrainMember = dTrainMembers.first!
        XCTAssertNotNil(dTrainMember.value(forKey: "train"),
                        "train not copied from source TrainMember")
        XCTAssertEqual(dTrainMember.value(forKey: "modelClass") as! String?, "GWR Hall",
                       "modelClass not copied from source TrainMember")
        XCTAssertEqual(dTrainMember.value(forKey: "numberOrName") as! String?, "Hogwarts Castle",
                       "numberOrName not copied from source TrainMember")
        XCTAssertEqual(dTrainMember.value(forKey: "details") as! String?, "Hogwarts Express Livery",
                       "details not copied from source TrainMember")
        XCTAssertEqual(dTrainMember.value(forKey: "notes") as! String?, "Not a Castle",
                       "notes not copied from source TrainMember")
        XCTAssertEqual(dTrainMember.value(forKey: "flipped") as! Bool, true,
                       "isFlipped not copied from source TrainMember")
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
        XCTAssertEqual(dTrainMembers.count, 1, "Expected train members after migration")
        
        let dTrainMember = dTrainMembers.first!
        XCTAssertEqual(dTrainMember.value(forKey: "modelClass") as! String?, "",
                       "modelClass not converted to empty string")
        XCTAssertEqual(dTrainMember.value(forKey: "numberOrName") as! String?, "",
                       "numberOrName not converted to empty string")
        XCTAssertEqual(dTrainMember.value(forKey: "details") as! String?, "",
                       "details not converted to empty string")
        XCTAssertEqual(dTrainMember.value(forKey: "notes") as! String?, "",
                       "notes not converted to empty string")
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
        XCTAssertEqual(dModels.count, 1, "Expected models after migration")

        let dSocket = dModels[0].value(forKey: "socket") as! NSManagedObject?
        XCTAssertNotNil(dSocket, "socket not created from Model")
        
        XCTAssertEqual(dSocket!.value(forKey: "title") as! String?, "PluX22",
                       "title not copied from source Model")
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
        XCTAssertEqual(dDecoderTypes.count, 1, "Expected decoder types after migration")
        
        let dDecoderType = dDecoderTypes.first!
        let dSocket = dDecoderType.value(forKey: "socket") as! NSManagedObject?
        XCTAssertNotNil(dSocket, "socket not created from DecoderType")
        
        XCTAssertEqual(dSocket?.value(forKey: "title") as! String?, "PluX22",
                       "title not copied from source DecoderType")
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
        XCTAssertEqual(dModels.count, 2, "Expected models after migration")

        let dSocket = dModels[0].value(forKey: "socket") as! NSManagedObject?
        XCTAssertNotNil(dSocket, "socket not created from Model")
        
        XCTAssertEqual(dModels[1].value(forKey: "socket") as! NSManagedObject?, dSocket,
                       "socket not re-used from previous Model")
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
        XCTAssertEqual(dModels.count, 2, "Expected models after migration")

        let dSocket = dModels[0].value(forKey: "socket") as! NSManagedObject?
        XCTAssertNotNil(dSocket, "socket not created from Model")
        
        XCTAssertNotEqual(dModels[1].value(forKey: "socket") as! NSManagedObject?, dSocket,
                          "socket incorrectly re-used from previous Model")
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
        XCTAssertEqual(dDecoderTypes.count, 2, "Expected decoder types after migration")
        
        let dSocket = dDecoderTypes[0].value(forKey: "socket") as! NSManagedObject?
        XCTAssertNotNil(dSocket, "socket not created from DecoderType")
        
        XCTAssertEqual(dDecoderTypes[1].value(forKey: "socket") as! NSManagedObject?, dSocket,
                       "socket not re-used from previous DecoderType")
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
        XCTAssertEqual(dDecoderTypes.count, 2, "Expected decoder types after migration")
        
        let dSocket = dDecoderTypes[0].value(forKey: "socket") as! NSManagedObject?
        XCTAssertNotNil(dSocket, "socket not created from DecoderType")

        XCTAssertNotEqual(dDecoderTypes[1].value(forKey: "socket") as! NSManagedObject?, dSocket,
                          "socket incorrectly re-used from previous DecoderType")
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
        XCTAssertEqual(dModels.count, 1, "Expected models after migration")
        
        let dSocket = dModels[0].value(forKey: "socket") as! NSManagedObject?
        XCTAssertNotNil(dSocket, "socket not created from Model")

        let dDecoderTypesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DecoderType")
        let dDecoderTypes = try managedObjectContext.fetch(dDecoderTypesFetchRequest)
        XCTAssertEqual(dDecoderTypes.count, 1, "Expected decoder types after migration")
        
        XCTAssertEqual(dDecoderTypes[0].value(forKey: "socket") as! NSManagedObject?, dSocket,
                       "socket not re-used from previous DecoderType")
    }
    
    /// Check that numberOfPins is set correctly for 4-pin NEM654.
    func testSocketPins4() throws {
        let sDecoderType = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                           insertInto: managedObjectContext)
        sDecoderType.setValue("ESU", forKey: "manufacturer")
        sDecoderType.setValue("50123", forKey: "productCode")
        sDecoderType.setValue("4-pin NEM654", forKey: "socket")

        try managedObjectContext.save()
        try performMigration()

        let dSocketsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Socket")
        let dSockets = try managedObjectContext.fetch(dSocketsFetchRequest)
        XCTAssertEqual(dSockets.count, 1, "Expected sockets after migration")
        
        let dSocket = dSockets.first!
        XCTAssertEqual(dSocket.value(forKey: "title") as! String?, "4-pin NEM654",
                       "title not copied from source DecoderType")
        XCTAssertEqual(dSocket.value(forKey: "numberOfPins") as! Int16, 4,
                       "numberOfPins not correctly calcluated")
    }

    /// Check that numberOfPins is set correctly for 6-pin NEM651.
    func testSocketPins6() throws {
        let sDecoderType = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                           insertInto: managedObjectContext)
        sDecoderType.setValue("ESU", forKey: "manufacturer")
        sDecoderType.setValue("50123", forKey: "productCode")
        sDecoderType.setValue("6-pin NEM651", forKey: "socket")

        try managedObjectContext.save()
        try performMigration()

        let dSocketsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Socket")
        let dSockets = try managedObjectContext.fetch(dSocketsFetchRequest)
        XCTAssertEqual(dSockets.count, 1, "Expected sockets after migration")
        
        let dSocket = dSockets.first!
        XCTAssertEqual(dSocket.value(forKey: "title") as! String?, "6-pin NEM651",
                       "title not copied from source DecoderType")
        XCTAssertEqual(dSocket.value(forKey: "numberOfPins") as! Int16, 6,
                       "numberOfPins not correctly calcluated")
    }

    /// Check that numberOfPins is set correctly for 8-pin NEM652.
    func testSocketPins8() throws {
        let sDecoderType = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                           insertInto: managedObjectContext)
        sDecoderType.setValue("ESU", forKey: "manufacturer")
        sDecoderType.setValue("50123", forKey: "productCode")
        sDecoderType.setValue("8-pin NEM652", forKey: "socket")

        try managedObjectContext.save()
        try performMigration()

        let dSocketsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Socket")
        let dSockets = try managedObjectContext.fetch(dSocketsFetchRequest)
        XCTAssertEqual(dSockets.count, 1, "Expected sockets after migration")
        
        let dSocket = dSockets.first!
        XCTAssertEqual(dSocket.value(forKey: "title") as! String?, "8-pin NEM652",
                       "title not copied from source DecoderType")
        XCTAssertEqual(dSocket.value(forKey: "numberOfPins") as! Int16, 8,
                       "numberOfPins not correctly calcluated")
    }

    /// Check that numberOfPins is set correctly for PluX8.
    func testSocketPinsPlux8() throws {
        let sDecoderType = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                           insertInto: managedObjectContext)
        sDecoderType.setValue("ESU", forKey: "manufacturer")
        sDecoderType.setValue("50123", forKey: "productCode")
        sDecoderType.setValue("PluX8", forKey: "socket")

        try managedObjectContext.save()
        try performMigration()

        let dSocketsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Socket")
        let dSockets = try managedObjectContext.fetch(dSocketsFetchRequest)
        XCTAssertEqual(dSockets.count, 1, "Expected sockets after migration")
        
        let dSocket = dSockets.first!
        XCTAssertEqual(dSocket.value(forKey: "title") as! String?, "PluX8",
                       "title not copied from source DecoderType")
        XCTAssertEqual(dSocket.value(forKey: "numberOfPins") as! Int16, 8,
                       "numberOfPins not correctly calcluated")
    }

    /// Check that numberOfPins is set correctly for PluX16.
    func testSocketPins16() throws {
        let sDecoderType = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                           insertInto: managedObjectContext)
        sDecoderType.setValue("ESU", forKey: "manufacturer")
        sDecoderType.setValue("50123", forKey: "productCode")
        sDecoderType.setValue("PluX16", forKey: "socket")

        try managedObjectContext.save()
        try performMigration()

        let dSocketsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Socket")
        let dSockets = try managedObjectContext.fetch(dSocketsFetchRequest)
        XCTAssertEqual(dSockets.count, 1, "Expected sockets after migration")
        
        let dSocket = dSockets.first!
        XCTAssertEqual(dSocket.value(forKey: "title") as! String?, "PluX16",
                       "title not copied from source DecoderType")
        XCTAssertEqual(dSocket.value(forKey: "numberOfPins") as! Int16, 16,
                       "numberOfPins not correctly calcluated")
    }

    /// Check that numberOfPins is set correctly for Next18.
    func testSocketPins18() throws {
        let sDecoderType = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                           insertInto: managedObjectContext)
        sDecoderType.setValue("ESU", forKey: "manufacturer")
        sDecoderType.setValue("50123", forKey: "productCode")
        sDecoderType.setValue("Next18", forKey: "socket")

        try managedObjectContext.save()
        try performMigration()

        let dSocketsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Socket")
        let dSockets = try managedObjectContext.fetch(dSocketsFetchRequest)
        XCTAssertEqual(dSockets.count, 1, "Expected sockets after migration")
        
        let dSocket = dSockets.first!
        XCTAssertEqual(dSocket.value(forKey: "title") as! String?, "Next18",
                       "title not copied from source DecoderType")
        XCTAssertEqual(dSocket.value(forKey: "numberOfPins") as! Int16, 18,
                       "numberOfPins not correctly calcluated")
    }

    /// Check that numberOfPins is set correctly for Next18-S.
    func testSocketPins18S() throws {
        let sDecoderType = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                           insertInto: managedObjectContext)
        sDecoderType.setValue("ESU", forKey: "manufacturer")
        sDecoderType.setValue("50123", forKey: "productCode")
        sDecoderType.setValue("Next18-S", forKey: "socket")

        try managedObjectContext.save()
        try performMigration()

        let dSocketsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Socket")
        let dSockets = try managedObjectContext.fetch(dSocketsFetchRequest)
        XCTAssertEqual(dSockets.count, 1, "Expected sockets after migration")
        
        let dSocket = dSockets.first!
        XCTAssertEqual(dSocket.value(forKey: "title") as! String?, "Next18-S",
                       "title not copied from source DecoderType")
        XCTAssertEqual(dSocket.value(forKey: "numberOfPins") as! Int16, 18,
                       "numberOfPins not correctly calcluated")
    }

    /// Check that numberOfPins is set correctly for 21MTC.
    func testSocketPins21() throws {
        let sDecoderType = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                           insertInto: managedObjectContext)
        sDecoderType.setValue("ESU", forKey: "manufacturer")
        sDecoderType.setValue("50123", forKey: "productCode")
        sDecoderType.setValue("21MTC", forKey: "socket")

        try managedObjectContext.save()
        try performMigration()

        let dSocketsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Socket")
        let dSockets = try managedObjectContext.fetch(dSocketsFetchRequest)
        XCTAssertEqual(dSockets.count, 1, "Expected sockets after migration")
        
        let dSocket = dSockets.first!
        XCTAssertEqual(dSocket.value(forKey: "title") as! String?, "21MTC",
                       "title not copied from source DecoderType")
        XCTAssertEqual(dSocket.value(forKey: "numberOfPins") as! Int16, 21,
                       "numberOfPins not correctly calcluated")
    }

    /// Check that numberOfPins is set correctly for PluX22.
    func testSocketPins22() throws {
        let sDecoderType = NSManagedObject(entity: sourceManagedObjectModel.entitiesByName["DecoderType"]!,
                                           insertInto: managedObjectContext)
        sDecoderType.setValue("ESU", forKey: "manufacturer")
        sDecoderType.setValue("50123", forKey: "productCode")
        sDecoderType.setValue("PluX22", forKey: "socket")

        try managedObjectContext.save()
        try performMigration()

        let dSocketsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Socket")
        let dSockets = try managedObjectContext.fetch(dSocketsFetchRequest)
        XCTAssertEqual(dSockets.count, 1, "Expected sockets after migration")
        
        let dSocket = dSockets.first!
        XCTAssertEqual(dSocket.value(forKey: "title") as! String?, "PluX22",
                       "title not copied from source DecoderType")
        XCTAssertEqual(dSocket.value(forKey: "numberOfPins") as! Int16, 22,
                       "numberOfPins not correctly calcluated")
    }
}
