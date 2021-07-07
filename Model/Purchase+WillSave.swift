//
//  Purchase+WillSave.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import Foundation
import CoreData

extension Purchase {
    public override func willSave() {
        super.willSave()
        
        let newDateForGrouping = Self.makeDateForGrouping(from: dateComponents)
        if dateForGrouping != newDateForGrouping { dateForGrouping = newDateForGrouping }

        let newDateForSort = Self.makeDateForSort(from: dateComponents)
        if dateForSort != newDateForSort { dateForSort = newDateForSort }
    }
}
