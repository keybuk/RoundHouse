//
//  ContentView.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 5/3/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationSplitView {
            AppSidebar()
        } content: {
            Text("Content")
        } detail: {
            Text("Detail")
        }
    }
}

 struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
