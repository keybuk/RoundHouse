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

    /// Check that we can store and retrieve DateComponents via the transformer.
    func testTransformer() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.dateComponents = DateComponents(year: 2020, month: 6, day: 13)

        try persistenceController.container.viewContext.save()
        persistenceController.container.viewContext.refreshAllObjects()

        XCTAssertEqual(purchase.dateComponents, DateComponents(year: 2020, month: 6, day: 13),
                       "dateComponents did not have expected value after refresh")
    }
    
    // MARK: purchaseMonth

    /// Check that we convert a date components to the UTC midnight on the first of the month.
    func testPurchaseMonth() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.dateComponents = DateComponents(year: 2005, month: 7, day: 18)

        XCTAssertEqual(purchase.purchaseMonth, Date(timeIntervalSince1970: 1120176000),
                       "purchaseMonth did not have expected value")
    }
    
    /// Check that we convert `nil` to `.distantPast`
    func testPurchaseMonthFromNil() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        XCTAssertEqual(purchase.purchaseMonth, Date.distantPast,
                       "purchaseMonth did not have expected value")
    }
    
    // MARK: dateForSort

    /// Check that we convert a date components to the UTC midnight.
    func testMakeDateForSort() throws {
        let dateForSort = Purchase.makeDateForSort(from: DateComponents(year: 2020, month: 6, day: 13))
        
        XCTAssertEqual(dateForSort, Date(timeIntervalSince1970: 1592006400),
                       "return value did not have expected value")
    }
    
    /// Check that we convert `nil` to `.distantPast`
    func testMakeDateForSortFromNil() throws {
        let dateForSort = Purchase.makeDateForSort(from: nil)
        
        XCTAssertEqual(dateForSort, Date.distantPast,
                       "return value did not have expected value")
    }

    /// Check that `dateForSort` is set from `dateComponents`.
    func testDateForSort() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.dateComponents = DateComponents(year: 2020, month: 6, day: 13)

        try persistenceController.container.viewContext.save()

        XCTAssertEqual(purchase.dateForSort, Date(timeIntervalSince1970: 1592006400),
                       "dateForSort did not have expected value")
    }

    /// Check that `dateForSort` is `.distantPast` when `dateComponents` is not set.
    func testDateForSortDistantPast() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        try persistenceController.container.viewContext.save()

        XCTAssertEqual(purchase.dateForSort, .distantPast,
                       "dateForSort did not have expected value")
    }
}
