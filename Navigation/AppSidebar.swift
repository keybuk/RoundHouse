//
//  AppSidebar.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/13/21.
//

import SwiftUI

extension Model.Classification {
    var imageName: String {
        switch self {
        case .dieselElectricLocomotive: return "tram"
        case .steamLocomotive: return "cablecar"
        case .coach: return "train.side.middle.car"
        case .wagon: return "train.side.middle.car"
        case .multipleUnit: return "train.side.front.car"
        case .departmental: return "wrench"
        case .noPrototype: return "paperplane"
        case .vehicle: return "bus"
        }
    }
}

struct AppSidebar: View {
    enum NavigationItem: Equatable, Hashable {
        case purchases
        case models(Model.Classification)
        case accessories
        case decoders
        case trains
    }

    @State var selection: NavigationItem? = .models(.dieselElectricLocomotive)

    var body: some View {
        List {
            // BUG(FB9191591) Sections cause issues when pushing NavigationLinks
            Section {
                NavigationLink(tag: NavigationItem.purchases, selection: $selection) {
                    PurchasesList()
                } label: {
                    Label("Purchases", systemImage: "bag")

                }
            }

            Section(header: Text("Models")) {
                ForEach(Model.Classification.allCases, id: \.self) { classification in
                    NavigationLink(tag: NavigationItem.models(classification), selection: $selection) {
                        ModelsList(classification: classification)
                    } label: {
                        Label("\(classification.pluralDescription)", systemImage: classification.imageName)
                    }
                }
            }

            Section(header: Text("Accessories")) {
                NavigationLink(tag: NavigationItem.accessories, selection: $selection) {
                    AccessoriesList()
                } label: {
                    Label("Accessories", systemImage: "ticket")
                }

                NavigationLink(tag: NavigationItem.decoders, selection: $selection) {
                    DecoderTypesList()
                } label: {
                    Label("Decoders", systemImage: "esim")
                }
            }
        }
        .frame(minWidth: 250)
    }
}

struct AppSidebar_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebar()
    }
}
