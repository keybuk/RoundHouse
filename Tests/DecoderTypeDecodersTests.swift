//
//  DecoderTypeDecodersTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import XCTest
import CoreData

@testable import RoundHouse

class DecoderTypeDecodersTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    // MARK: addDecoder

    /// Check that we can add a decoder to an empty type.
    func testAddFirstDecoder() {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)
        let decoder = decoderType.addDecoder()

        XCTAssertEqual(decoder.type, decoderType)
        XCTAssertNotNil(decoderType.decoders)
        XCTAssertTrue(decoderType.decoders?.contains(decoder) ?? false)
    }

    /// Check that we can add a second decoder to a type.
    func testAddSecondDecoder() {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)

        for _ in 0...0 {
            let decoder = Decoder(context: persistenceController.container.viewContext)
            decoderType.addToDecoders(decoder)
        }

        let decoder = decoderType.addDecoder()

        XCTAssertEqual(decoder.type, decoderType)
        XCTAssertNotNil(decoderType.decoders)
        XCTAssertTrue(decoderType.decoders?.contains(decoder) ?? false)

    }

    // MARK: removeDecoder

    /// Check that we can remove the only decoder from a type.
    func testRemoveDecoder() {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)

        var decoders: [Decoder] = []
        for _ in 0...0 {
            let decoder = Decoder(context: persistenceController.container.viewContext)
            decoderType.addToDecoders(decoder)
            decoders.append(decoder)
        }

        decoderType.removeDecoder(decoders[0])

        XCTAssertTrue(decoders[0].isDeleted)
        XCTAssertNil(decoders[0].type)
        XCTAssertFalse(decoderType.decoders?.contains(decoders[0]) ?? false)
    }

    /// Check that we can remove a second decoder from a type.
    func testRemoveSecondDecoder() {
        let decoderType = DecoderType(context: persistenceController.container.viewContext)

        var decoders: [Decoder] = []
        for _ in 0...1 {
            let decoder = Decoder(context: persistenceController.container.viewContext)
            decoderType.addToDecoders(decoder)
            decoders.append(decoder)
        }

        decoderType.removeDecoder(decoders[1])

        XCTAssertTrue(decoders[1].isDeleted)
        XCTAssertNil(decoders[1].type)
        XCTAssertFalse(decoderType.decoders?.contains(decoders[1]) ?? false)
        XCTAssertTrue(decoderType.decoders?.contains(decoders[0]) ?? false)
    }
}
