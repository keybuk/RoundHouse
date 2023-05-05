//
//  ModelEnumTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 7/1/21.
//

import XCTest

@testable import RoundHouse

class ModelEnumTests: XCTestCase {
    // MARK: Model.Classification

    /// Check that the raw values of the enums are as expected.
    ///
    /// This test ensures stability of the database content.
    func testClassificationRawValue() throws {
        for classification in Model.Classification.allCases {
            switch (classification.rawValue, classification) {
            case (1, .dieselElectricLocomotive): break
            case (2, .steamLocomotive): break
            case (3, .coach): break
            case (4, .wagon): break
            case (5, .multipleUnit): break
            case (6, .departmental): break
            case (7, .noPrototype): break
            case (8, .vehicle): break
            case (9, .accessory): break
            default:
                XCTFail("Classification has incorrect rawValue for \(classification)")
            }
        }
    }
    
    /// Check that the enum can be initialized from a raw value.
    ///
    /// This test ensures stability of the database content.
    func testClassificationFromRawValue() throws {
        for rawValue in (1 as Int16)...(8 as Int16) {
            switch (rawValue, Model.Classification(rawValue: rawValue)) {
            case (1, .dieselElectricLocomotive): break
            case (2, .steamLocomotive): break
            case (3, .coach): break
            case (4, .wagon): break
            case (5, .multipleUnit): break
            case (6, .departmental): break
            case (7, .noPrototype): break
            case (8, .vehicle): break
            case (9, .accessory): break
            default:
                XCTFail("Classification has incorrect value for rawValue \(rawValue)")
            }
        }
    }
    
    /// Check that enum is nil when initialized with zero.
    func testClassificationFromZero() throws {
        XCTAssertNil(Model.Classification(rawValue: 0), "Classification has incorrect value")
    }
    
    // MARK: Model.Era

    /// Check that the raw values of the enums are as expected.
    ///
    /// This test ensures stability of the database content.
    func testEraRawValue() throws {
        for era in Model.Era.allCases {
            switch (era.rawValue, era) {
            case (1, .pioneering): break
            case (2, .preGrouping): break
            case (3, .theBigFour): break
            case (4, .brSteamEarlyCrest): break
            case (5, .brSteamLateCrest): break
            case (6, .brCorporateBluePreTOPS): break
            case (7, .brCorporateBluePostTOPS): break
            case (8, .brSectorisation): break
            case (9, .initialPrivatisation): break
            case (10, .rebuildingOfTheRailways): break
            case (11, .currentEra): break
            default:
                XCTFail("Era has incorrect rawValue for \(era)")
            }
        }
    }
    
    /// Check that the enum can be initialized from a raw value.
    ///
    /// This test ensures stability of the database content.
    func testEraFromRawValue() throws {
        for rawValue in (1 as Int16)...(11 as Int16) {
            switch (rawValue, Model.Era(rawValue: rawValue)) {
            case (1, .pioneering?): break
            case (2, .preGrouping?): break
            case (3, .theBigFour?): break
            case (4, .brSteamEarlyCrest?): break
            case (5, .brSteamLateCrest?): break
            case (6, .brCorporateBluePreTOPS?): break
            case (7, .brCorporateBluePostTOPS?): break
            case (8, .brSectorisation?): break
            case (9, .initialPrivatisation?): break
            case (10, .rebuildingOfTheRailways?): break
            case (11, .currentEra?): break
            default:
                XCTFail("Era has incorrect value for rawValue \(rawValue)")
            }
        }
    }
    
    /// Check that enum is nil when initialized with zero.
    func testEraFromZero() throws {
        XCTAssertNil(Model.Era(rawValue: 0), "Era has incorrect value")
    }

    // MARK: Model.Disposition

    /// Check that the raw values of the enums are as expected.
    ///
    /// This test ensures stability of the database content.
    func testDispositionRawValue() throws {
        for disposition in Model.Disposition.allCases {
            switch (disposition.rawValue, disposition) {
            case (1, .normal): break
            case (2, .collectorItem): break
            case (3, .spareParts): break
            default:
                XCTFail("Disposition has incorrect rawValue for \(disposition)")
            }
        }
    }
    
    /// Check that the enum can be initialized from a raw value.
    ///
    /// This test ensures stability of the database content.
    func testDispositionFromRawValue() throws {
        for rawValue in (1 as Int16)...(3 as Int16) {
            switch (rawValue, Model.Disposition(rawValue: rawValue)) {
            case (1, .normal): break
            case (2, .collectorItem): break
            case (3, .spareParts): break
            default:
                XCTFail("Disposition has incorrect value for rawValue \(rawValue)")
            }
        }
    }
    
    /// Check that enum is nil when initialized with zero.
    func testDispositionFromZero() throws {
        XCTAssertNil(Model.Disposition(rawValue: 0), "Disposition has incorrect value")
    }
}
