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
    
    // También inicializamos el ViewModel de onboarding
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    
    init() {
        // Inicializamos la instancia compartida de OnboardingViewModel
        OnboardingViewModel.shared = onboardingViewModel
        
        // Almacenamos la referencia global a AuthViewModel
        sharedAuthViewModel = authViewModel
    }
    
    var body: some Scene {
        WindowGroup {
            // Usamos AuthContainerView como vista principal
            AuthContainerView()
                .environmentObject(authViewModel)
                .environmentObject(onboardingViewModel)
        }
    }
}
