//
//  DecoderType+WillSave.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 7/6/21.
//

import Foundation
import CoreData

extension DecoderType {
    public override func willSave() {
        super.willSave()
        
        let newRemainingStock = makeRemainingStock()
        if remainingStock != newRemainingStock { remainingStock = newRemainingStock }
    }
}
