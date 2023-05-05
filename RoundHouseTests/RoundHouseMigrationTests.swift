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
        sPurchase.setValue(0, forKey: "conditionRawValue")
        sPurchase.setValue(NSDecimalNumber(value: 100), forKey: "valuation")
        sPurchase.setValue("Test", forKey: "notes")

        try managedObjectContext.save()
        try performMigration()

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
        XCTAssertEqual(dPurchase.value(forKey: "date") as! DateComponents?,
                       DateComponents(year: 2010, month: 12, day: 25),
                       "Purchase.date not copied from source")
        XCTAssertEqual(dPurchase.value(forKey: "store") as! String?, "Hattons",
                       "Purchase.store not copied from source")
        XCTAssertEqual(dPurchase.value(forKey: "price") as! NSDecimalNumber?,
                       NSDecimalNumber(value: 129.99),
                       "Purchase.price not copied from source Purchase")
        XCTAssertEqual(dPurchase.value(forKey: "conditionRawValue") as! Int16, 0,
                       "Purchase.conditionRawValue not copied from source")
        XCTAssertEqual(dPurchase.value(forKey: "valuation") as! NSDecimalNumber?,
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
        sModel.setValue(0, forKey: "eraRawValue")
        sModel.setValue(0, forKey: "dispositionRawValue")
        sModel.setValue("PluX22", forKey: "socket")
        sModel.setValue("5-pole", forKey: "motor")
        sModel.setValue(DateComponents(year: 2020, month: 6, day: 17), forKey: "lastOil")
        sModel.setValue(DateComponents(year: 2020, month: 6, day: 19), forKey: "lastRun")
        sModel.setValue("Test", forKey: "notes")

        try managedObjectContext.save()
        try performMigration()

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
        XCTAssertEqual(dModel.value(forKey: "eraRawValue") as! Int16, 0,
                       "Model.eraRawValue not copied from source")
        XCTAssertEqual(dModel.value(forKey: "dispositionRawValue") as! Int16, 0,
                       "Model.dispositionRawValue not copied from source")
        XCTAssertEqual(dModel.value(forKey: "socket") as! String?, "PluX22",
                       "Model.socket not copied from source")
        XCTAssertEqual(dModel.value(forKey: "motor") as! String?, "5-pole",
                       "Model.motor not copied from source")
        XCTAssertEqual(dModel.value(forKey: "lastOil") as! DateComponents?,
                       DateComponents(year: 2020, month: 6, day: 17),
                       "Model.lastOil not copied from source")
        XCTAssertEqual(dModel.value(forKey: "lastRun") as! DateComponents?,
                       DateComponents(year: 2020, month: 6, day: 19),
                       "Model.lastRun not copied from source")
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
        XCTAssertEqual(dModel.value(forKey: "socket") as! String?, "",
                       "Model.socket not converted to empty string")
        XCTAssertEqual(dModel.value(forKey: "motor") as! String?, "",
                       "Model.motor not converted to empty string")
        XCTAssertEqual(dModel.value(forKey: "notes") as! String?, "",
                       "Model.notes not converted to empty string")
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
        sDecoderType.setValue("PluX22", forKey: "socket")
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
        XCTAssertEqual(dDecoderType.value(forKey: "socket") as! String?, "PluX22",
                       "DecoderType.socket not copied from source")
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
        XCTAssertEqual(dDecoderType.value(forKey: "socket") as! String?, "",
                       "DecoderType.socket not converted to empty string")
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
        XCTAssertEqual(dDecoder.value(forKey: "firmwareDate") as! DateComponents?,
                       DateComponents(year: 2019, month: 9, day: 15),
                       "Decoder.firmwareDate not copied from source")
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
}
