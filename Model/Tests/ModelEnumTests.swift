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
            switch classification {
            case .dieselElectricLocomotive:
                XCTAssertEqual(classification.rawValue, 1, "rawValue has incorrect value")
            case .steamLocomotive:
                XCTAssertEqual(classification.rawValue, 2, "rawValue has incorrect value")
            case .coach:
                XCTAssertEqual(classification.rawValue, 3, "rawValue has incorrect value")
            case .wagon:
                XCTAssertEqual(classification.rawValue, 4, "rawValue has incorrect value")
            case .multipleUnit:
                XCTAssertEqual(classification.rawValue, 5, "rawValue has incorrect value")
            case .departmental:
                XCTAssertEqual(classification.rawValue, 6, "rawValue has incorrect value")
            case .noPrototype:
                XCTAssertEqual(classification.rawValue, 7, "rawValue has incorrect value")
            case .vehicle:
                XCTAssertEqual(classification.rawValue, 8, "rawValue has incorrect value")
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
            switch era {
            case .pioneering:
                XCTAssertEqual(era.rawValue, 1, "rawValue has incorrect value")
            case .preGrouping:
                XCTAssertEqual(era.rawValue, 2, "rawValue has incorrect value")
            case .theBigFour:
                XCTAssertEqual(era.rawValue, 3, "rawValue has incorrect value")
            case .brSteamEarlyCrest:
                XCTAssertEqual(era.rawValue, 4, "rawValue has incorrect value")
            case .brSteamLateCrest:
                XCTAssertEqual(era.rawValue, 5, "rawValue has incorrect value")
            case .brCorporateBluePreTOPS:
                XCTAssertEqual(era.rawValue, 6, "rawValue has incorrect value")
            case .brCorporateBluePostTOPS:
                XCTAssertEqual(era.rawValue, 7, "rawValue has incorrect value")
            case .brSectorisation:
                XCTAssertEqual(era.rawValue, 8, "rawValue has incorrect value")
            case .initialPrivatisation:
                XCTAssertEqual(era.rawValue, 9, "rawValue has incorrect value")
            case .rebuildingOfTheRailways:
                XCTAssertEqual(era.rawValue, 10, "rawValue has incorrect value")
            case .currentEra:
                XCTAssertEqual(era.rawValue, 11, "rawValue has incorrect value")
            default:
                XCTFail("Era \(era) not expected")
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
            switch disposition {
            case .normal:
                XCTAssertEqual(disposition.rawValue, 1, "rawValue has incorrect value")
            case .collectorItem:
                XCTAssertEqual(disposition.rawValue, 2, "rawValue has incorrect value")
            case .spareParts:
                XCTAssertEqual(disposition.rawValue, 3, "rawValue has incorrect value")
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
