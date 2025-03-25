//
//  LoginView.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 11/03/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showForgotPassword = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            // Fondo
            Color.background
                .ignoresSafeArea()
            
            // Contenido principal
            ScrollView {
                VStack(spacing: 32) {
                    // Logo y título
                    VStack(spacing: 80) {
                        LyrahLogo(size: 100)
                        
                        Text("Iniciar Sesión")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 60)
                    
                    // Formulario de login
                    VStack(spacing: 20) {
                        // Campo de email/usuario
                        LyrahTextField(
                            placeholder: "Email o nombre de usuario",
                            text: $authViewModel.loginCredentials.email,
                            icon: "envelope.fill"
                        )
                        
                        // Campo de contraseña
                        LyrahTextField(
                            placeholder: "Contraseña",
                            text: $authViewModel.loginCredentials.password,
                            icon: "lock.fill",
                            isSecure: true
                        )
                        
                        // ¿Olvidaste tu contraseña?
                        HStack {
                            Spacer()
                            Button(action: {
                                showForgotPassword = true
                            }) {
                                Text("¿Olvidaste tu contraseña?")
                                    .font(.subheadline)
                                    .foregroundColor(.adicionalOne)
                            }
                        }
                        .padding(.top, -10)
                    }
                    
                    // Botón de inicio de sesión
                    LyrahButton(
                        title: "Iniciar Sesión",
                        action: {
                            authViewModel.login()
                        },
                        isLoading: authViewModel.authState == .authenticating
                    )
                    
                    // Separador "O continuar con"
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        
                        Text("O continuar con")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)
                    
                    // Botones de inicio de sesión social
                    VStack(spacing: 12) {
                        SocialSignInButton(service: "apple") {
                            
                        }
                        
                        SocialSignInButton(service: "google") {
                            
                        }
                    }
                    
                    // ¿No tienes una cuenta? Regístrate
                    HStack {
                        Text("¿No tienes una cuenta?")
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            authViewModel.isShowingRegister = true
                        }) {
                            Text("Regístrate")
                                .fontWeight(.semibold)
                                .foregroundColor(.adicionalOne)
                        }
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            
            // Alerta para mostrar mensajes de error
            if authViewModel.showAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        authViewModel.showAlert = false
                    }
                
                VStack {
                    Text("Aviso")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    Text(authViewModel.alertMessage)
                        .font(.body)
                        .multilineTextAlignment(.center)
                    
                    Button("Aceptar") {
                        authViewModel.showAlert = false
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 40)
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.background)
                .cornerRadius(12)
                .shadow(radius: 10)
                .padding(.horizontal, 40)
                .transition(.scale)
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            // Aquí iría la vista de recuperación de contraseña
            Text("Recuperación de contraseña")
                .font(.title)
                .padding()
        }
    }
}

// Vista de previsualización
#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
