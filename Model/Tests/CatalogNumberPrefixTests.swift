//
//  CatalogNumberPrefixTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/24/18.
//

import XCTest

@testable import RoundHouse

class CatalogNumberPrefixTests: XCTestCase {
    // MARK: Hornby

    /// Check that a basic Hornby R2702 number isn't modified.
    func testHornby() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "R2702")
        XCTAssertEqual(catalogNumberPrefix, "R2702")
    }

    /// Check that an old three-digit Hornby number isn't modified.
    func testOldHornby() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "R296")
        XCTAssertEqual(catalogNumberPrefix, "R296")
    }

    /// Check that a Hornby additional running number loses the suffix letter.
    func testHornbyRunningNumber() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "R2290D")
        XCTAssertEqual(catalogNumberPrefix, "R2290")
    }

    /// Check that a Hornby TTS number loses the TTS suffix.
    func testHornbyTTS() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "R3390TTS")
        XCTAssertEqual(catalogNumberPrefix, "R3390")
    }

    // MARK: Bachmann

    /// Check that a basic Bachmann 31-654 number isn't modified.
    func testBachmann() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "31-654")
        XCTAssertEqual(catalogNumberPrefix, "31-654")
    }

    /// Check that a Bachmann additional running number loses the suffix.
    func testBachmannRunningNumber() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "32-452A")
        XCTAssertEqual(catalogNumberPrefix, "32-452")
    }

    /// Check that a Bachmann special edition loses the Z suffix.
    func testBachmannSpecialEdition() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "31-657Z")
        XCTAssertEqual(catalogNumberPrefix, "31-657")
    }

    /// Check that a Bachmann South West Digital special edition loses the QDS suffix.
    func testBachmannSWD() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "31-650QDS")
        XCTAssertEqual(catalogNumberPrefix, "31-650")
    }

    // MARK: Dapol

    /// Check that a Dapol 4D-022-000 number has the last part removed, but dash preserved.
    func testDapol() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "4D-006-000")
        XCTAssertEqual(catalogNumberPrefix, "4D-006-")
    }

    /// Check that a Dapol sound fitted locomotive has the suffix and last number removed.
    func testDapolSound() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "4D-022-001S")
        XCTAssertEqual(catalogNumberPrefix, "4D-022-")
    }

    /// Check that a Dapol special edition for Hattons has the whole last part removed.
    func testDapolHattons() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "4D-009-HAT05")
        XCTAssertEqual(catalogNumberPrefix, "4D-009-")
    }

    /// Check that a Dapol special edition for DCC Concepts has the whole last part removed.
    func testDapolDCCConcepts() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "4D-009-DCC1")
        XCTAssertEqual(catalogNumberPrefix, "4D-009-")
    }

    /// Check that the unusual Gaugemaster special edition numbering is unmodified.
    func testDapolGaugemaster() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "DAGM101")
        XCTAssertEqual(catalogNumberPrefix, "DAGM101")
    }

    /// Check that the unusual Olivia's Trains special edition numbering is unmodified.
    func testDapolOlivias() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "OLIV001")
        XCTAssertEqual(catalogNumberPrefix, "OLIV001")
    }

    // MARK: Hattons

    /// Check that a Hattons H4-PH-012 number has the last part removed, but dash preserved.
    func testHattons() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "H4-P-012")
        XCTAssertEqual(catalogNumberPrefix, "H4-P-")
    }

    // MARK: Realtrack

    /// Check that a Realtrack 143-212 number has the last part removed.
    func testRealtrack() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "143-212")
        XCTAssertEqual(catalogNumberPrefix, "143-")
    }

    // MARK: Oxford Rail/Diecast

    /// Check that an Oxford Rail OR763TO002 number is preserved.
    func testOxford() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from:  "OR763TO002")
        XCTAssertEqual(catalogNumberPrefix, "OR763TO002")
    }

    /// Check that an Oxford Rail alternate running number has the letter suffix removed.
    func testOxfordRunningNumber() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "OR763TO002B")
        XCTAssertEqual(catalogNumberPrefix, "OR763TO002")
    }

    /// Check that an Oxford Diecast 76CONT001 number is preserved.
    func testOxfordDiecast() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "76CONT001")
        XCTAssertEqual(catalogNumberPrefix, "76CONT001")
    }

    /// Check that an Oxford Diecast 76CONT00124 number has the running number removed.
    func testOxfordDiecastRunningNumber() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "76CONT00124")
        XCTAssertEqual(catalogNumberPrefix, "76CONT001")
    }

    // MARK: Others

    /// Check that a Heljan 3356 number is unmodified.
    func testHeljan() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "3356")
        XCTAssertEqual(catalogNumberPrefix, "3356")
    }

    /// Check that a Rapido 13501 number is unmodified.
    func testRapido() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "13501")
        XCTAssertEqual(catalogNumberPrefix, "13501")
    }

    /// Check that an all-letters catalog number is unmodified.
    func testAllLetter() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "GLV")
        XCTAssertEqual(catalogNumberPrefix, "GLV")
    }
    
    /// Check that the empty string returns an empty string.
    func testEmptyString() throws {
        let catalogNumberPrefix = Purchase.makeCatalogNumberPrefix(from: "")
        XCTAssertEqual(catalogNumberPrefix, "")
    }
}
