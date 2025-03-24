//
//  LyrahComponents.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 11/03/25.
//

import SwiftUI

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
