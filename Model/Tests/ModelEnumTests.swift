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
        for rawValue in (1 as Int16)...(5 as Int16) {
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
                XCTFail("Classification has incorrect value")
            }
        }
    }
    
    /// Check that enum is nil when initialized with zero.
    func testClassificationFromZero() throws {
        XCTAssertNil(Model.Classification(rawValue: 0), "Classification has incorrect value")
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
        for rawValue in (1 as Int16)...(5 as Int16) {
            switch (rawValue, Model.Disposition(rawValue: rawValue)) {
            case (1, .normal): break
            case (2, .collectorItem): break
            case (3, .spareParts): break
            default:
                XCTFail("Disposition has incorrect value")
            }
        }
    }
    
    /// Check that enum is nil when initialized with zero.
    func testDispositionFromZero() throws {
        XCTAssertNil(Model.Disposition(rawValue: 0), "Disposition has incorrect value")
    }

}
