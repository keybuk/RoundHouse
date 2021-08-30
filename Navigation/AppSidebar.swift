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
        case .dieselElectricLocomotive: return "railway.locomotive"
        case .steamLocomotive: return "railway.steam"
        case .coach: return "railway.coach"
        case .wagon: return "railway.wagon"
        case .multipleUnit: return "railway.demu"
        case .departmental: return "railway.departmental"
        case .noPrototype: return "railway.noprototype"
        case .vehicle: return "railway.vehicle"
        }
    }
}

struct AppSidebar: View {
    enum NavigationItem: RawRepresentable, Equatable, Hashable {
        case purchases
        case models(Model.Classification)
        case accessories
        case decoders
        case trains

        init?(rawValue: String) {
            switch rawValue {
            case "purchases": self = .purchases
            case "models.dieselElectricLocomotive": self = .models(.dieselElectricLocomotive)
            case "models.steamLocomotive": self = .models(.steamLocomotive)
            case "models.coach": self = .models(.coach)
            case "models.wagon": self = .models(.wagon)
            case "models.multipleUnit": self = .models(.multipleUnit)
            case "models.departmental": self = .models(.departmental)
            case "models.noPrototype": self = .models(.noPrototype)
            case "models.vehicle": self = .models(.vehicle)
            case "accessories": self = .accessories
            case "decoders": self = .decoders
            case "trains": self = .trains
            default: return nil
            }
        }

        var rawValue: String {
            switch self {
            case .purchases: return "purchases"
            case .models(.dieselElectricLocomotive): return "models.dieselElectricLocomotive"
            case .models(.steamLocomotive): return "models.steamLocomotive"
            case .models(.coach): return "models.coach"
            case .models(.wagon): return "models.wagon"
            case .models(.multipleUnit): return "models.multipleUnit"
            case .models(.departmental): return "models.departmental"
            case .models(.noPrototype): return "models.noPrototype"
            case .models(.vehicle): return "models.vehicle"
            case .accessories: return "accessories"
            case .decoders: return "decoders"
            case .trains: return "trains"
            }
        }
    }

    // Can't set a default value, and whenever we present just AppSidebar on iOS/iPadOS this has
    // the value `nil` so we can't compare against that to set a default anywhere else.
    @SceneStorage("selection") var selection: NavigationItem?// = .models(.dieselElectricLocomotive)

    var body: some View {
        List {
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
                        Label("\(classification.pluralDescription)", image: classification.imageName)
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
