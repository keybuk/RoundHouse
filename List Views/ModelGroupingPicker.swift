//
//  ModelGroupingPicker.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/14/21.
//

import SwiftUI

extension Model {
    enum Grouping {
        case modelClass
        case era
        case livery
    }
}

struct ModelGroupingPicker: View {
    @Binding var grouping: Model.Grouping

    var body: some View {
        Picker("Group By", selection: $grouping) {
            Text("Class")
                .tag(Model.Grouping.modelClass)
            Text("Era")
                .tag(Model.Grouping.era)
            Text("Livery")
                .tag(Model.Grouping.livery)
        }
        .pickerStyle(.segmented)
    }
}

struct ModelGroupingPicker_Previews: PreviewProvider {
    static var previews: some View {
        ModelGroupingPicker(grouping: .constant(.modelClass))
    }
}
