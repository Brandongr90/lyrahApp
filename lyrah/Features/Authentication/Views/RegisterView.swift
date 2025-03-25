//
//  RegisterView.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 11/03/25.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Fondo
            Color.background
                .ignoresSafeArea()
            
            // Contenido principal
            ScrollView {
                VStack(spacing: 32) {
                    // Logo y título
                    VStack(spacing: 16) {
                        LyrahLogo(size: 100)
                        
                        Text("Crear Cuenta")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 40)
                    
                    // Formulario de registro
                    VStack(spacing: 20) {
                        // Campo de email
                        LyrahTextField(
                            placeholder: "Email",
                            text: $authViewModel.registerCredentials.email,
                            icon: "envelope.fill"
                        )
                        
                        // Campo de contraseña
                        LyrahTextField(
                            placeholder: "Contraseña",
                            text: $authViewModel.registerCredentials.password,
                            icon: "lock.fill",
                            isSecure: true
                        )
                        
                        // Campo de confirmar contraseña
                        LyrahTextField(
                            placeholder: "Confirmar contraseña",
                            text: $authViewModel.confirmPassword,
                            icon: "lock.fill",
                            isSecure: true
                        )
                    }
                    
                    // Texto informativo sobre términos y condiciones
                    Text("Al registrarte, aceptas nuestros Términos y Condiciones y Política de Privacidad")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Botón de registro
                    LyrahButton(
                        title: "Crear Cuenta",
                        action: {
                            authViewModel.register()
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
                    
                    // ¿Ya tienes una cuenta? Inicia sesión
                    HStack {
                        Text("¿Ya tienes una cuenta?")
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            authViewModel.isShowingRegister = false
                        }) {
                            Text("Inicia sesión")
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
    }
}

// Vista de previsualización
#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}
