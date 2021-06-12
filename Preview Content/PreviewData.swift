//
//  PreviewData.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/12/21.
//

import CoreData

extension PersistenceController {
    static var preview: PersistenceController = {
        let persistenceController = PersistenceController(inMemory: true)
        let viewContext = persistenceController.container.viewContext

        let model = Model(context: viewContext)
        model.number = "1234"

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return persistenceController
    }()
}
