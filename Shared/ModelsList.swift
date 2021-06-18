//
//  ModelsList.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/12/21.
//

import SwiftUI

struct ModelsList: View {
    var classification: Model.Classification?

    var body: some View {
        VStack {
            Text("Models")
            if let classification = classification {
                Text("(\(classification.description))")
                    .font(.caption)
            }
        }
    }
}

struct ModelsList_Previews: PreviewProvider {
    static var previews: some View {
        ModelsList(classification: .dieselElectricLocomotive)
    }
}
