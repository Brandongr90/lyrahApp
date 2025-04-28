//
//  WelcomeView.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 11/03/25.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.bgIndigo]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Estrellas
                StarsView()
                    .ignoresSafeArea()
                
                // Contenido principal
                VStack {
                    // Logo en la parte superior
                    HStack {
                        LyrahLogo(size: 100, useWhite: true)
                            .padding(.leading, 24)
                            // Posiciona el logo justo debajo del safe area
                            .padding(.top, safeAreaTop())
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Texto de bienvenida
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bienvenido(a) a tu")
                                .font(.montserrat(fontStyle: .title2))
                                .foregroundColor(.white.opacity(0.9))
                            Text("espacio de bienestar.")
                                .font(.montserrat(fontStyle: .title, fontWeight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 24)
                        .padding(.bottom, 40)
                        Spacer()
                    }
                    
                    // Botones de navegación
                    VStack(spacing: 20) {
                        NavigationLink(destination: RegisterView()) {
                            HStack(spacing: 12) {
                                Text("Registrarme")
                                    .font(.montserrat(fontStyle: .body, fontWeight: .semibold))
                                    .foregroundColor(.white)
                                Image(systemName: "sparkle")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .symbolEffect(.bounce, options: .repeat(3), value: isAnimating)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 28)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.white.opacity(0.3), .blueButtonLight.opacity(0.5)]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .shadow(color: .blueButtonLight.opacity(0.2), radius: 12, x: 0, y: 4)
                        }
                        .opacity(isAnimating ? 1 : 0)
                        
                        NavigationLink(destination: LoginView()) {
                            Text("Ya tengo una cuenta")
                                .font(.montserrat(fontStyle: .footnote, fontWeight: .regular))
                                .foregroundColor(.white.opacity(0.8))
                                .underline()
                        }
                        .opacity(isAnimating ? 1 : 0)
                    }
                    .padding(.bottom, 40)
                }
                .zIndex(1)
            }
            .onAppear {
                // Asignamos el estado sin animar para evitar reacomodación de layout
                isAnimating = true
            }
            .navigationBarHidden(true)
        }
    }
    
    // Función para obtener el safe area superior
    private func safeAreaTop() -> CGFloat {
        guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first else { return 20 }
        return window.safeAreaInsets.top
    }
}

struct StarsView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<70, id: \.self) { _ in
                    Star(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                }
            }
        }
    }
}

struct Star: View {
    let xPos: CGFloat
    let yPos: CGFloat
    let size: CGFloat
    let phase: Double
    let period: Double
    let minOpacity: Double
    let maxOpacity: Double
    
    init(maxWidth: CGFloat, maxHeight: CGFloat) {
        self.xPos = CGFloat.random(in: 0..<maxWidth)
        self.yPos = CGFloat.random(in: 0..<maxHeight)
        self.size = CGFloat.random(in: 2.0...5.0)
        self.phase = Double.random(in: 0..<(2 * .pi))
        self.period = Double.random(in: 2.5...5.0)
        self.minOpacity = Double.random(in: 0.1...0.3)
        self.maxOpacity = Double.random(in: 0.8...1.0)
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let sineValue = sin((2 * .pi / period) * time + phase)
            let normalized = (sineValue + 1) / 2
            let currentOpacity = minOpacity + normalized * (maxOpacity - minOpacity)
            Circle()
                .frame(width: size, height: size)
                .foregroundColor(.white)
                .position(x: xPos, y: yPos)
                .opacity(currentOpacity)
                .blur(radius: size > 3.5 ? 0.5 : 0)
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthViewModel())
}
