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
}
