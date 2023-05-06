//
//  PurchaseDateTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import XCTest
import CoreData

@testable import RoundHouse

class PurchaseDateTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    // MARK: purchaseMonth

    /// Check that we convert a date components to the UTC midnight on the first of the month.
    func testMonth() throws {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!

        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.date = calendar.date(from: DateComponents(year: 2005, month: 7, day: 18))

        XCTAssertEqual(purchase.month, Date(timeIntervalSince1970: 1120176000),
                       "purchaseMonth did not have expected value")
    }
    
    /// Check that we convert `nil` to `.distantPast`
    func testMonthFromNil() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        XCTAssertEqual(purchase.month, Date.distantPast,
                       "purchaseMonth did not have expected value")
    }
}
