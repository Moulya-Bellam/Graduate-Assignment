//
//  part_2App.swift
//  part-2
//
//  Created by Mounesh on 4/11/25.
//

import SwiftUI

@main
struct part_2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
