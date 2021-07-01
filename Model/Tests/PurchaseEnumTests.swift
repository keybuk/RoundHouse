//
//  PurchaseEnumTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 7/1/21.
//

import XCTest

@testable import RoundHouse

class PurchaseEnumTests: XCTestCase {
    // MARK: Purchase.Condition

    /// Check that the raw values of the enums are as expected.
    ///
    /// This test ensures stability of the database content.
    func testConditionRawValue() throws {
        for condition in Purchase.Condition.allCases {
            switch condition {
            case .new:
                XCTAssertEqual(condition.rawValue, 1, "rawValue has incorrect value")
            case .likeNew:
                XCTAssertEqual(condition.rawValue, 2, "rawValue has incorrect value")
            case .used:
                XCTAssertEqual(condition.rawValue, 3, "rawValue has incorrect value")
            case .usedInWrongBox:
                XCTAssertEqual(condition.rawValue, 4, "rawValue has incorrect value")
            case .handmade:
                XCTAssertEqual(condition.rawValue, 5, "rawValue has incorrect value")
            }
        }
    }
    
    /// Check that the enum can be initialized from a raw value.
    ///
    /// This test ensures stability of the database content.
    func testConditionFromRawValue() throws {
        for rawValue in (1 as Int16)...(5 as Int16) {
            switch (rawValue, Purchase.Condition(rawValue: rawValue)) {
            case (1, .new): break
            case (2, .likeNew): break
            case (3, .used): break
            case (4, .usedInWrongBox): break
            case (5, .handmade): break
            default:
                XCTFail("Condition has incorrect value")
            }
        }
    }
    
    /// Check that enum is nil when initialized with zero.
    func testConditionFromZero() throws {
        XCTAssertNil(Purchase.Condition(rawValue: 0), "Condition has incorrect value")
    }
}
