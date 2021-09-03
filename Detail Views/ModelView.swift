//
//  ModelDetailView.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/30/21.
//

import SwiftUI

/// ModelView is the navigation target for showing details on a selected model.
struct ModelView: View {
    @ObservedObject var model: Model

    var body: some View {
        ModelDetail(model: model)
            .navigationTitle(model.classTitle)
    }
}

struct ModelView_Previews: PreviewProvider {
    static var previews: some View {
        ModelView(model: PreviewData.shared.models["R3804"]!)
            .environment(\.managedObjectContext, PreviewData.shared.viewContext)
    }
}
