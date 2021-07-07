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
    
    // MARK: dateForGrouping

    /// Check that we convert a date components to the UTC midnight on the first of the month.
    func testMakeDateForGrouping() throws {
        let dateForGrouping = Purchase.makeDateForGrouping(from: DateComponents(year: 2005, month: 7, day: 18))
        
        XCTAssertEqual(dateForGrouping, Date(timeIntervalSince1970: 1120176000),
                       "return value did not have expected value")
    }
    
    /// Check that we convert `nil` to `.distantPast`
    func testMakeDateForGroupingFromNil() throws {
        let dateForGrouping = Purchase.makeDateForGrouping(from: nil)
        
        XCTAssertEqual(dateForGrouping, Date.distantPast,
                       "return value did not have expected value")
    }
    
    /// Check that the dateForGrouping field is set on save.
    func testDateForGrouping() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)
        purchase.dateComponents = DateComponents(year: 2005, month: 7, day: 18)

        try persistenceController.container.viewContext.save()

        XCTAssertEqual(purchase.dateForGrouping, Date(timeIntervalSince1970: 1120176000),
                       "dateForSort did not have expected value")
    }

    /// Check dateForGrouping contains `.distantPast` when `dateComponents`  is`nil`.
    func testNilDateForGrouping() throws {
        let purchase = Purchase(context: persistenceController.container.viewContext)

        try persistenceController.container.viewContext.save()

        XCTAssertEqual(purchase.dateForGrouping, Date.distantPast,
                       "dateForSort did not have expected value")
    }

    // MARK: dateForSort

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
