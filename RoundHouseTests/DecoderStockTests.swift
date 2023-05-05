//
//  DecoderStockTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 7/6/21.
//

import XCTest
import CoreData

@testable import RoundHouse

class DecoderStockTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    // MARK: isFitted

    /// Check that a decoder is fitted when it has a model set.
    func testIsFitted() throws {
        let decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.type = DecoderType(context: persistenceController.container.viewContext)
        decoder.model = Model(context: persistenceController.container.viewContext)
        decoder.model!.purchase = Purchase(context: persistenceController.container.viewContext)

        XCTAssertEqual(decoder.isFitted, true)
    }

    /// Check that a decoder is not fitted when it does not have a model set.
    func testIsNotFitted() throws {
        let decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.type = DecoderType(context: persistenceController.container.viewContext)

        XCTAssertEqual(decoder.isFitted, false)
    }

    // MARK: isAllocated

    /// Check that a decoder is allocated when it has a value for sound author.
    func testSoundAuthorIsAllocated() throws {
        let decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.type = DecoderType(context: persistenceController.container.viewContext)
        decoder.soundAuthor = "Legomanbiffo"

        XCTAssertEqual(decoder.isAllocated, true)
    }

    /// Check that a decoder is not allocated when it has an empty value for sound author.
    func testEmptySoundAuthorIsNotAllocated() throws {
        let decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.type = DecoderType(context: persistenceController.container.viewContext)
        decoder.soundAuthor = ""

        XCTAssertEqual(decoder.isAllocated, false)
    }

    /// Check that a decoder is allocated when it has a value for sound project.
    func testSoundProjectIsAllocated() throws {
        let decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.type = DecoderType(context: persistenceController.container.viewContext)
        decoder.soundProject = "Class 68"

        XCTAssertEqual(decoder.isAllocated, true)
    }

    /// Check that a decoder is not allocated when it has an empty value for sound project.
    func testEmptySoundProjectIsNotAllocated() throws {
        let decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.type = DecoderType(context: persistenceController.container.viewContext)
        decoder.soundProject = ""

        XCTAssertEqual(decoder.isAllocated, false)
    }

    /// Check that a decoder is allocated when it has a value for sound project version.
    func testSoundProjectVersionIsAllocated() throws {
        let decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.type = DecoderType(context: persistenceController.container.viewContext)
        decoder.soundProjectVersion = "1.0"

        XCTAssertEqual(decoder.isAllocated, true)
    }

    /// Check that a decoder is not allocated when it has an empty value for sound project version.
    func testEmptySoundProjectVersionIsNotAllocated() throws {
        let decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.type = DecoderType(context: persistenceController.container.viewContext)
        decoder.soundProjectVersion = ""

        XCTAssertEqual(decoder.isAllocated, false)
    }

    /// Check that a decoder is allocated when it has a value for sound settings.
    func testSoundSettingsIsAllocated() throws {
        let decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.type = DecoderType(context: persistenceController.container.viewContext)
        decoder.soundSettings = "Newer Horns (CV43 = 1)"

        XCTAssertEqual(decoder.isAllocated, true)
    }

    /// Check that a decoder is not allocated when it has an empty value for sound settings.
    func testEmptySoundSettingsIsNotAllocated() throws {
        let decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.type = DecoderType(context: persistenceController.container.viewContext)
        decoder.soundSettings = ""

        XCTAssertEqual(decoder.isAllocated, false)
    }

    /// Check that a decoder is allocated when it has complete sound information.
    func testIsAllocated() throws {
        let decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.type = DecoderType(context: persistenceController.container.viewContext)
        decoder.soundAuthor = "Legomanbiffo"
        decoder.soundProject = "Class 68"
        decoder.soundProjectVersion = "1.0"
        decoder.soundSettings = "Newer Horns (CV43 = 1)"

        XCTAssertEqual(decoder.isAllocated, true)
    }

    /// Check that a decoder is not allocated when it has no sound information.
    func testIsNotAllocated() throws {
        let decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.type = DecoderType(context: persistenceController.container.viewContext)

        XCTAssertEqual(decoder.isAllocated, false)
    }

    // MARK: isSpare

    /// Check that a decoder is spare when it has no model or sound project.
    func testIsSpare() throws {
        let decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.type = DecoderType(context: persistenceController.container.viewContext)

        XCTAssertEqual(decoder.isSpare, true)
    }

    /// Check that a decoder is not spare when it has a model fitted.
    func testFittedIsNotSpare() throws {
        let decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.type = DecoderType(context: persistenceController.container.viewContext)
        decoder.model = Model(context: persistenceController.container.viewContext)
        decoder.model!.purchase = Purchase(context: persistenceController.container.viewContext)
        assert(decoder.isFitted)

        XCTAssertEqual(decoder.isSpare, false)
    }

    /// Check that a decoder is not spare when it has a sound project allocated.
    func testAllocatedIsNotSpare() throws {
        let decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.type = DecoderType(context: persistenceController.container.viewContext)
        decoder.soundAuthor = "Legomanbiffo"
        decoder.soundProject = "Class 68"
        decoder.soundProjectVersion = "1.0"
        decoder.soundSettings = "Newer Horns (CV43 = 1)"
        assert(decoder.isAllocated)

        XCTAssertEqual(decoder.isSpare, false)
    }

    /// Check that a decoder is not spare when it has a model fitted and sound project allocated.
    func testFittedAndAllocatedIsNotSpare() throws {
        let decoder = Decoder(context: persistenceController.container.viewContext)
        decoder.type = DecoderType(context: persistenceController.container.viewContext)
        decoder.model = Model(context: persistenceController.container.viewContext)
        decoder.model!.purchase = Purchase(context: persistenceController.container.viewContext)
        decoder.soundAuthor = "Legomanbiffo"
        decoder.soundProject = "Class 68"
        decoder.soundProjectVersion = "1.0"
        decoder.soundSettings = "Newer Horns (CV43 = 1)"
        assert(decoder.isFitted)
        assert(decoder.isAllocated)

        XCTAssertEqual(decoder.isSpare, false)
    }
}
