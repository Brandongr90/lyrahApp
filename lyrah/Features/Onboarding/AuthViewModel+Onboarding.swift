//
//  AuthViewModel+Onboarding.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 26/03/25.
//

import SwiftUI

// Extensión de AuthViewModel para integrar el flujo de onboarding
extension AuthViewModel {
    
    // Nuevo método para mostrar la vista adecuada según el estado
    @ViewBuilder
    func getContentView() -> some View {
        switch authState {
        case .unauthenticated:
            NavigationView {
                if isShowingRegister {
                    RegisterView()
                } else {
                    WelcomeView()
                }
            }
            
        case .authenticating:
            LoadingView()
            
        case .authenticated(let user):
            if !user.hasProfile {
                // El usuario está autenticado pero no tiene perfil,
                // mostrar el flujo de onboarding
                OnboardingRegisterGeneralView()
            } else if onboardingState == .notStarted {
                // El onboarding tradicional de la app
                OnboardingPlaceholderView()
            } else {
                // Pantalla principal
                HomeScreenPlaceholderView(username: user.username)
            }
            
        case .error:
            // Vista de error, podría ser personalizada
            Text("Ha ocurrido un error. Por favor intenta nuevamente.")
                .padding()
            
            Button("Reintentar") {
                self.authState = .unauthenticated
            }
            .buttonStyle(.bordered)
            .tint(.adicionalOne)
        }
    }
    
    // Método para convertir OnboardingData a un perfil para la API
    func createProfileFromOnboardingData(_ onboardingData: OnboardingData) -> [String: Any] {
        var profileData: [String: Any] = [
            "user_id": self.getUserId() ?? "",
            "first_name": onboardingData.basicProfile.firstName,
            "last_name": onboardingData.basicProfile.lastName
        ]
        
        // Agregar género si está disponible
        if let gender = onboardingData.basicProfile.gender {
            profileData["gender"] = gender.rawValue
        }
        
        // Estos campos son opcionales según la estructura de la base de datos
        profileData["bio"] = ""
        
        return profileData
    }
    
    // Método para preparar los datos de la encuesta para la API
    func prepareSurveyDataForAPI(profileId: String, onboardingData: OnboardingData) -> [String: Any] {
        let surveyData: [String: Any] = [
            "profile_id": profileId,
            "consent_given": onboardingData.consentGiven,
            "responses": onboardingData.surveyResponses.map { response in
                return [
                    "question_id": response.questionId,
                    "selected_option_id": response.selectedOptionId,
                    "score": response.score
                ]
            }
        ]
        
        return surveyData
    }
}
