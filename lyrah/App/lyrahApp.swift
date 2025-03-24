//
//  lyrahApp.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 11/03/25.
//

import SwiftUI

@main
struct lyrahApp: App {
    // Creamos una instancia del ViewModel para compartir en toda la app
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            // Usamos AuthContainerView como vista principal
            AuthContainerView()
                .environmentObject(authViewModel)
        }
    }
}
