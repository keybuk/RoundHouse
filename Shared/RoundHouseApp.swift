//
//  RoundHouseApp.swift
//  Shared
//
//  Created by Scott James Remnant on 6/12/21.
//

import SwiftUI

@main
struct RoundHouseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
