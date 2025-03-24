//
//  LyrahComponents.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 11/03/25.
//

import SwiftUI

// Campo de texto estilizado para los formularios
struct LyrahTextField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String? // Nombre del SF Symbol
    var isSecure: Bool = false
    
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            // Icono si existe
            if let iconName = icon {
                Image(systemName: iconName)
                    .foregroundColor(isEditing ? Color.adicionalTwo : Color.secondary)
                    .frame(width: 24)
            }
            
            // Campo de texto
            if isSecure {
                SecureField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                TextField(placeholder, text: $text, onEditingChanged: { editing in
                    isEditing = editing
                })
                .autocapitalization(.none)
                .disableAutocorrection(true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isEditing ? Color.adicionalTwo : Color.clear, lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Botón principal con gradiente
struct LyrahButton: View {
    var title: String
    var action: () -> Void
    var gradientColors: [Color] = [.primary, .secondary]
    var isLoading: Bool = false
    
    var body: some View {
        Button(action: {
            if !isLoading {
                action()
            }
        }) {
            ZStack {
                // Contenido del botón
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                } else {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .foregroundColor(.white)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isLoading ? 0.7 : 1.0)
    }
}

// Botón secundario con borde
struct LyrahSecondaryButton: View {
    var title: String
    var action: () -> Void
    var color: Color = .primary
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .foregroundColor(color)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Botón de autenticación con servicios externos
struct SocialSignInButton: View {
    var service: String // "apple" o "google"
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(service == "apple" ? "AppleIcon" : "GoogleIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text("Continuar con \(service == "apple" ? "Apple" : "Google")")
                    .font(.headline)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(service == "apple" ? .white : .black)
            .background(service == "apple" ? Color.black : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: service == "apple" ? 0 : 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Indicador de carga global para la app
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Cargando...")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 8)
            }
            .padding(25)
            .background(Color.primary.opacity(0.8))
            .cornerRadius(16)
        }
    }
}

// Vista para mostrar el logo de Lyrah
struct LyrahLogo: View {
    var size: CGFloat = 150
    var useWhite: Bool = false
    
    var body: some View {
        Image(useWhite ? "LogoWhite" : "LogoPrimary")
            .resizable()
            .scaledToFit()
            .frame(width: size)
    }
}
