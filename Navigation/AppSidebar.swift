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

enum NavigationItem: Hashable {
    case purchases
    case models(Model.Classification)
    case accessories
    case decoders
    case trains
}

//extension NavigationItem: RawRepresentable {
//    init?(rawValue: String) {
//        switch rawValue {
//        case "purchases": self = .purchases
//        case "models.dieselElectricLocomotive": self = .models(.dieselElectricLocomotive)
//        case "models.steamLocomotive": self = .models(.steamLocomotive)
//        case "models.coach": self = .models(.coach)
//        case "models.wagon": self = .models(.wagon)
//        case "models.multipleUnit": self = .models(.multipleUnit)
//        case "models.departmental": self = .models(.departmental)
//        case "models.noPrototype": self = .models(.noPrototype)
//        case "models.vehicle": self = .models(.vehicle)
//        case "accessories": self = .accessories
//        case "decoders": self = .decoders
//        case "trains": self = .trains
//        default: return nil
//        }
//    }
//
//    var rawValue: String {
//        switch self {
//        case .purchases: return "purchases"
//        case .models(.dieselElectricLocomotive): return "models.dieselElectricLocomotive"
//        case .models(.steamLocomotive): return "models.steamLocomotive"
//        case .models(.coach): return "models.coach"
//        case .models(.wagon): return "models.wagon"
//        case .models(.multipleUnit): return "models.multipleUnit"
//        case .models(.departmental): return "models.departmental"
//        case .models(.noPrototype): return "models.noPrototype"
//        case .models(.vehicle): return "models.vehicle"
//        case .accessories: return "accessories"
//        case .decoders: return "decoders"
//        case .trains: return "trains"
//        }
//    }
//}

struct AppSidebar: View {
    // We can't set a default value for @SceneStorage when the type is an optional, and we want a
    // default value for macOS and non-compact views so they open to real data instead of
    // placeholders.
    //
    // But NavigationLink requires that the selection Binding be to an optional since this will
    // have the value `nil` when showing just AppSidebar on iOS or compact iPad views. And for that
    // same reason we can't just compare the selection against `nil` to return the default value.
    //
    // Workaround this limitation using an extra storage item that effectively works as a "does the
    // scene storage have a selection?" test.
//    @SceneStorage("AppSidebar.hasSelection") var hasSelection: Bool = false
//    @SceneStorage("AppSidebar.selection") var savedSelection: NavigationItem?
//    let defaultSelection: NavigationItem = .models(.dieselElectricLocomotive)

//    var selection: Binding<NavigationItem?> {
//        Binding {
//            hasSelection ? savedSelection : defaultSelection
//        } set: {
//            hasSelection = true
//            savedSelection = $0
//        }
//    }

    @Binding var selection: NavigationItem?
    
    var body: some View {
        List(selection: $selection) {
            Section {
                NavigationLink(value: NavigationItem.purchases) {
                    Label("Purchases", systemImage: "bag")
                }
            }

            Section("Models") {
                ForEach(Model.Classification.allCases, id: \.self) { classification in
                    NavigationLink(value: NavigationItem.models(classification)) {
                        Label("\(classification.pluralDescription)", image: classification.imageName)
                    }
                }
            }

            Section("Accessories") {
                NavigationLink(value: NavigationItem.accessories) {
                    Label("Accessories", systemImage: "ticket")
                }

                NavigationLink(value: NavigationItem.decoders) {
                    Label("Decoders", systemImage: "esim")
                }
            }
        }
        #if os(macOS)
        .navigationSplitViewColumnWidth(min: 200, ideal: 200)
        #endif
    }
}

struct AppSidebar_Previews: PreviewProvider {
    struct Preview: View {
        @State private var selection: NavigationItem? = NavigationItem.models(.dieselElectricLocomotive)
        var body: some View {
            AppSidebar(selection: $selection)
        }
    }
    
    static var previews: some View {
        NavigationSplitView {
            Preview()
                .environment(\.managedObjectContext, PreviewData.shared.viewContext)
        } detail: {
            Text("Detail!")
        }
    }

}
