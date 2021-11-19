//
//  Binding+Default.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 9/6/21.
//

import SwiftUI

extension Binding where Value: Equatable {
    init(_ source: Binding<Value?>, default defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { newValue in
                source.wrappedValue = newValue
        })
    }
}
