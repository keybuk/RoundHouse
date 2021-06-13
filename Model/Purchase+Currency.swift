//
//  Purchase+Currency.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/13/21.
//

import Foundation

extension Purchase {
    var price: Decimal? {
        get { priceRawValue as Decimal? }
        set { priceRawValue = newValue as NSDecimalNumber? }
    }

    var valuation: Decimal? {
        get { valuationRawValue as Decimal? }
        set { valuationRawValue = newValue as NSDecimalNumber? }
    }
}
