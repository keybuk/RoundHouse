//
//  SecureDateComponentsTransformerTests.swift
//  RoundHouseTests
//
//  Created by Scott James Remnant on 5/4/23.
//

import XCTest

@testable import RoundHouse

final class SecureDateComponentsTransformerTests: XCTestCase {
    func testTransformation() throws {
        let inputComponents = NSDateComponents()
        inputComponents.year = 2023
        inputComponents.month = 5
        inputComponents.day = 4

        let transformer = SecureDateComponentsTransformer()
        let storedValue = transformer.reverseTransformedValue(inputComponents)

        XCTAssertNotNil(storedValue)
        XCTAssertTrue(storedValue! is NSData)

        let transformedValue = transformer.transformedValue(storedValue)

        XCTAssertNotNil(transformedValue)
        XCTAssertTrue(transformedValue! is NSDateComponents)

        let outputComponents = transformedValue! as! NSDateComponents
        XCTAssertEqual(outputComponents.year, 2023)
        XCTAssertEqual(outputComponents.month, 5)
        XCTAssertEqual(outputComponents.day, 4)
    }
}
