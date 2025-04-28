//
//  AuthContainerView.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 11/03/25.
//

import SwiftUI

struct AuthContainerView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            // Mostramos la vista correspondiente según el estado de autenticación
            if case .authenticated(let user) = authViewModel.authState {
                // Si el usuario está autenticado, verificamos si necesita completar el onboarding
                if !user.hasProfile {
                    // Si no tiene perfil, mostrar el flujo de onboarding nuevo
                    OnboardingRegisterGeneralView()
                } else if authViewModel.onboardingState == .notStarted {
                    // Si tiene perfil pero falta el onboarding tradicional de la app
                    OnboardingPlaceholderView()
                } else {
                    // Mostrar la vista principal de la app
                    HomeScreenPlaceholderView(username: user.username)
                }
            } else if case .authenticating = authViewModel.authState {
                // Mostrar pantalla de carga durante autenticación
                LoadingView()
            } else if case .error(let message) = authViewModel.authState {
                // Mostrar pantalla de error
                VStack(spacing: 20) {
                    Text("Ha ocurrido un error")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(message)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Button("Reintentar") {
                        authViewModel.authState = .unauthenticated
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.adicionalOne)
                    .cornerRadius(10)
                }
                .padding()
            } else {
                // Si el usuario no está autenticado, mostramos la pantalla de bienvenida
                // o las vistas de login/registro según corresponda
                NavigationView {
                    if authViewModel.isShowingRegister {
                        RegisterView()
                    } else {
                        if authViewModel.authState == .unauthenticated {
                            WelcomeView()
                        } else {
                            LoginView()
                        }
                    }
                }
            }
        }
        .alert(isPresented: $authViewModel.showAlert) {
            Alert(
                title: Text("Aviso"),
                message: Text(authViewModel.alertMessage),
                dismissButton: .default(Text("Aceptar"))
            )
        }
    }
}

// Vista placeholder para el onboarding (se implementará después)
struct OnboardingPlaceholderView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("¡Bienvenido a Lyrah!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Vamos a configurar tu perfil para personalizar tu experiencia.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Image(systemName: "person.crop.circle.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.adicionalOne)
                .padding()
            
            Text("(Vista de onboarding - A implementar)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
            
            // Botón para simular la finalización del onboarding
            LyrahButton(title: "Finalizar onboarding (simulación)", action: {
                authViewModel.onboardingState = .completed
            })
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .padding(.top, 80)
    }
}

// Vista placeholder para la pantalla principal (se implementará después)
struct HomeScreenPlaceholderView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var username: String
    
    var body: some View {
        ZStack {
            // Fondo con gradiente
            LinearGradient.primaryGradient
                .opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("¡Hola, \(username)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Esta es la pantalla principal de Lyrah")
                    .font(.title3)
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.red)
                    .padding()
                
                Text("(Pantalla de inicio - A implementar)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Botón para cerrar sesión
                LyrahButton(
                    title: "Cerrar Sesión",
                    action: {
                        authViewModel.logout()
                    },
                    gradientColors: [.red.opacity(0.7), .red]
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .padding(.top, 80)
        }
    }
}

// Vista de previsualización
#Preview {
    AuthContainerView()
        .environmentObject(AuthViewModel())
}
