//
//  AppContent.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 7/21/22.
//

import SwiftUI

struct AppContent: View {
    @Binding var selection: NavigationItem?
    
    var body: some View {
        switch selection {
        case .purchases:
            PurchasesList()
        case .models(let classification):
            ModelsList(classification: classification)
        case .accessories:
            AccessoriesList()
        case .decoders:
            DecoderTypesList()
        default:
            Text("Content")
        }
    }
}

struct AppContent_Previews: PreviewProvider {
    struct Preview: View {
        @State var selection: NavigationItem? = .models(.dieselElectricLocomotive)
        
        var body: some View {
            AppContent(selection: $selection)
        }
    }
    static var previews: some View {
        Preview()
            .environment(\.managedObjectContext, PreviewData.shared.viewContext)
    }
}
