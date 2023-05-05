//
//  Purchase+Currency.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/13/21.
//

import Foundation

extension Purchase {
    /// `priceRawValue` as `Decimal`.
    var price: Decimal? {
        get { priceRawValue as Decimal? }
        set { priceRawValue = newValue as NSDecimalNumber? }
    }

    /// Returns a format style for `price` based on the currency.
    var priceFormatStyle: Decimal.FormatStyle.Currency {
        return .init(code: priceCurrency!)
    }

    /// `valuationRawValue` as `Decimal`.
    var valuation: Decimal? {
        get { valuationRawValue as Decimal? }
        set { valuationRawValue = newValue as NSDecimalNumber? }
    }

    /// Returns a format style for `valuation` based on the currency.
    var valuationFormatStyle: Decimal.FormatStyle.Currency {
        return .init(code: valuationCurrency!)
    }
}
