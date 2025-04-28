//
//  OnboardingProgressView.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 26/03/25.
//

import SwiftUI

struct OnboardingProgressView: View {
    let progress: Float
    let title: String
    
    var body: some View {
        VStack(spacing: 6) {
            // Título de la sección
            Text(title)
                .font(.montserrat(fontStyle: .headline, fontWeight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            // Barra de progreso
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Fondo de la barra
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    // Progreso
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.adicionalOne, .adicionalTwo]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(progress), height: 6)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 6)
            
            // Indicador de progreso en texto
            Text("\(Int(progress * 100))%")
                .font(.montserrat(fontStyle: .caption, fontWeight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingProgressView(progress: 0.25, title: "Datos Personales")
        OnboardingProgressView(progress: 0.5, title: "Bienestar Emocional")
        OnboardingProgressView(progress: 0.75, title: "Relaciones Personales")
    }
    .padding()
}
