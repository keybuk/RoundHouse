//
//  DecoderTypeStockTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 2/1/20.
//

import XCTest
import CoreData

@testable import RoundHouse

class DecoderTypeStockTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    // MARK: isStocked

    /// Check that a decoder type is considered stocked when it has a minimum stock set, even when not stocked.
    func testIsStocked() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.minimumStock = 5
        decoderType.remainingStock = 0

        XCTAssertEqual(decoderType.isStocked, true)
    }

    /// Check that a decoder type is considered stocked when it has remaining stock, even when minimum stock is not set.
    func testRemainingIsStocked() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.minimumStock = 0
        decoderType.remainingStock = 5

        XCTAssertEqual(decoderType.isStocked, true)
    }

    /// Check that a decoder type is not considered stocked when we don't have any and don't want any.
    func testIsNotStocked() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.minimumStock = 0
        decoderType.remainingStock = 0

        XCTAssertEqual(decoderType.isStocked, false)
    }

    // MARK: isStockLow

    /// Check that stock is considered low when the remaining stock is below the minimum stock.
    func testIsStockLow() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.minimumStock = 5
        decoderType.remainingStock = 2

        XCTAssertEqual(decoderType.isStockLow, true)
    }

    /// Check that stock is considered low when we're out of stock is below the minimum stock.
    func testOutOfStockIsStockLow() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.minimumStock = 5
        decoderType.remainingStock = 0

        XCTAssertEqual(decoderType.isStockLow, true)
    }

    /// Check that stock is not considered low when the remaining stock is equal to the minimum stock.
    func testIsNotStockLow() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.minimumStock = 5
        decoderType.remainingStock = 5

        XCTAssertEqual(decoderType.isStockLow, false)
    }

    /// Check that stock is not considered low when the remaining stock is greater than the minimum stock.
    func testExcessIsNotStockLow() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.minimumStock = 5
        decoderType.remainingStock = 11

        XCTAssertEqual(decoderType.isStockLow, false)
    }

    /// Check that stock is not considered low when we have stock of something we wouldn't ordinarily have.
    func testUnstockedIsNotStockLow() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        decoderType.minimumStock = 0
        decoderType.remainingStock = 0

        XCTAssertEqual(decoderType.isStockLow, false)
    }

    // MARK: makeRemainingStock

    /// Check that we correctly calculate the remaining stock ignoring fitted and allocated decoders.
    func testMakeRemainingStock() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)

        var decoder = Decoder(context: persistenceController.container.viewContext)
        decoderType.addToDecoders(decoder)

        decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.model = Model(context: persistenceController.container.viewContext)
        decoder.model!.purchase = Purchase(context: persistenceController.container.viewContext)
        decoderType.addToDecoders(decoder)

        decoder = Decoder(context: persistenceController.container.viewContext)
        decoderType.addToDecoders(decoder)

        decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.soundAuthor = "Legomanbiffo"
        decoder.soundProject = "Class 68"
        decoder.soundProjectVersion = "1.0"
        decoder.soundSettings = "Newer Horns (CV43 = 1)"
        decoderType.addToDecoders(decoder)

        let remainingStock = decoderType.makeRemainingStock()
        XCTAssertEqual(remainingStock, 2)
    }

    /// Check that we correctly calculate zero when a decoder type has no decoders.
    func testMakeRemainingStockEmpty() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)

        let remainingStock = decoderType.makeRemainingStock()
        XCTAssertEqual(remainingStock, 0)
    }

    /// Check that we correctly calculate zero when all decoders are fitted or allocated.
    func testMakeRemainingStockNoSpare() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)

        var decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.model = Model(context: persistenceController.container.viewContext)
        decoder.model!.purchase = Purchase(context: persistenceController.container.viewContext)
        decoderType.addToDecoders(decoder)

        decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.soundAuthor = "Legomanbiffo"
        decoder.soundProject = "Class 68"
        decoder.soundProjectVersion = "1.0"
        decoder.soundSettings = "Newer Horns (CV43 = 1)"
        decoderType.addToDecoders(decoder)

        let remainingStock = decoderType.makeRemainingStock()
        XCTAssertEqual(remainingStock, 0)
    }
    
    /// Check that remainingStock is set on save.
    func testRemainingStock() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)

        var decoder = Decoder(context: persistenceController.container.viewContext)
        decoderType.addToDecoders(decoder)

        decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.model = Model(context: persistenceController.container.viewContext)
        decoder.model!.purchase = Purchase(context: persistenceController.container.viewContext)
        decoderType.addToDecoders(decoder)

        decoder = Decoder(context: persistenceController.container.viewContext)
        decoderType.addToDecoders(decoder)

        decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.soundAuthor = "Legomanbiffo"
        decoder.soundProject = "Class 68"
        decoder.soundProjectVersion = "1.0"
        decoder.soundSettings = "Newer Horns (CV43 = 1)"
        decoderType.addToDecoders(decoder)

        try persistenceController.container.viewContext.save()

        XCTAssertEqual(decoderType.remainingStock, 2, "remainingStock not set on save")
    }

    /// Check that remainingStock is set to zero when a type has no decoders.
    func testRemainingStockEmpty() throws {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)

        try persistenceController.container.viewContext.save()

        XCTAssertEqual(decoderType.remainingStock, 0, "remainingStock not set on save")
    }
}
