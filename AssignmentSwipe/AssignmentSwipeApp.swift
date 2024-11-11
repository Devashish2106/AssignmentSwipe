//
//  AssignmentSwipeApp.swift
//  AssignmentSwipe
//
//  Created by Devashish Ghanshani on 10/11/24.
//

import SwiftUI

@main
struct AssignmentSwipeApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var networkMonitor = NetworkMonitor()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(networkMonitor)
        }
    }
}
