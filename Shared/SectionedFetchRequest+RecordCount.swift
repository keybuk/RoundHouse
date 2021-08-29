//
//  SectionedFetchRequest+RecordCount.swift
//  SectionedFetchRequest+RecordCount
//
//  Created by Scott James Remnant on 8/28/21.
//

import SwiftUI

extension SectionedFetchResults {
    /// The total number of elements in all sections.
    var recordCount: Int { reduce(0, { $0 + $1.count }) }
}

