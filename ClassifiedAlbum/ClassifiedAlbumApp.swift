//
//  ClassifiedAlbumApp.swift
//  ClassifiedAlbum
//
//  Created by Kohei Ikeda on 2022/05/23.
//

import SwiftUI

@main
struct ClassifiedAlbumApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
