//
//  PTRApp.swift
//  PTR
//
//  Created by V, Kalaivani V. (623-Extern) on 12/10/21.
//

import SwiftUI

@main
struct PTRApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
