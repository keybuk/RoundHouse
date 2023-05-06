//
//  ContentView.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/12/21.
//

import SwiftUI

struct ContentView: View {
    //    @SceneStorage("AppSidebar.selection") var savedSelection: NavigationItem?
    @State var selection: NavigationItem? = NavigationItem.models(.dieselElectricLocomotive)
    @State var path = NavigationPath()
    
    var body: some View {
        NavigationSplitView {
            AppSidebar(selection: $selection)
        } content: {
            AppContent(selection: $selection)
        } detail: {
            NavigationStack(path: $path) {
                AppDetail()
            }
        }
        .onChange(of: selection) { _ in
            path.removeLast(path.count)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PreviewData.shared.viewContext)
    }
}
