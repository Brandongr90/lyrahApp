//
//  Onboarding1.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 11/03/25.
//

import SwiftUI

// Estructura para representar cada paso del onboarding
struct OnboardingStep {
    let image: String    // Nombre del sistema de la imagen o recurso personalizado
    let title: String
    let description: String
}

struct OnboardingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentStep = 0
    
    // Pasos de onboarding - Puedes personalizarlos
    let steps = [
        OnboardingStep(
            image: "heart.fill",
            title: "Bienestar Integral",
            description: "Lyrah te ayuda a monitorear y mejorar todos los aspectos de tu bienestar personal."
        ),
        OnboardingStep(
            image: "chart.line.uptrend.xyaxis",
            title: "Seguimiento Personalizado",
            description: "Realiza encuestas periódicas para ver tu progreso y recibir recomendaciones personalizadas."
        ),
        OnboardingStep(
            image: "person.fill.checkmark",
            title: "Áreas de Mejora",
            description: "Identifica y trabaja en las áreas que más importan para tu bienestar personal."
        )
    ]
    
    var body: some View {
        ZStack {
            // Fondo con degradado
            LinearGradient.blueGradient
                .opacity(0.2)
                .ignoresSafeArea()
            
            VStack {
                // Botón de omitir en la parte superior (excepto en el último paso)
                if currentStep < steps.count - 1 {
                    HStack {
                        Spacer()
                        Button("Omitir") {
                            // Ir directamente al formulario de perfil
                            currentStep = steps.count
                        }
                        .foregroundColor(.adicionalOne)
                        .padding()
                    }
                }
                
                // Si estamos en los pasos de introducción
                if currentStep < steps.count {
                    // Contenido del paso actual
                    VStack(spacing: 40) {
                        Spacer()
                        
                        // Imagen
                        Image(systemName: steps[currentStep].image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.adicionalOne)
                            .padding()
                        
                        // Texto
                        VStack(spacing: 16) {
                            Text(steps[currentStep].title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(steps[currentStep].description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 24)
                        }
                        
                        Spacer()
                        
                        // Indicadores de paso
                        HStack(spacing: 8) {
                            ForEach(0..<steps.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentStep ? Color.adicionalOne : Color.gray.opacity(0.3))
                                    .frame(width: 10, height: 10)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Botón de siguiente
                        LyrahButton(
                            title: "Siguiente",
                            action: {
                                withAnimation {
                                    currentStep += 1
                                }
                            },
                            gradientColors: [.adicionalOne, .adicionalTwo]
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                } else {
                    // Formulario para completar el perfil
                    ProfileFormView(isOnboarding: true)
                }
            }
        }
        .transition(.slide)
        .animation(.easeInOut, value: currentStep)
    }
}

// Vista de formulario de perfil (a implementar completamente)
struct ProfileFormView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let isOnboarding: Bool // Indica si estamos en el proceso de onboarding
    
    // Estados para los campos del formulario
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var birthdate = Date()
    @State private var gender = "No especificado"
    @State private var selectedAreasOfImprovement: [Int] = []
    @State private var selectedWellnessActivities: [Int] = []
    
    // Opciones para el selector de género
    let genderOptions = ["No especificado", "Masculino", "Femenino", "No binario", "Otro"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Título
                VStack(spacing: 8) {
                    Text(isOnboarding ? "Completa tu perfil" : "Editar perfil")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Esta información nos ayudará a personalizar tu experiencia")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 12)
                
                // Avatar/foto (placeholder)
                ZStack {
                    Circle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                        .foregroundColor(.primary.opacity(0.7))
                    
                    Circle()
                        .stroke(Color.adicionalOne, lineWidth: 3)
                        .frame(width: 100, height: 100)
                }
                .overlay(
                    Circle()
                        .fill(Color.adicionalTwo)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        )
                        .shadow(radius: 2)
                        .offset(x: 35, y: 35)
                )
                
                // Formulario básico
                VStack(spacing: 16) {
                    // Nombre
                    LyrahTextField(
                        placeholder: "Nombre",
                        text: $firstName,
                        icon: "person.fill"
                    )
                    
                    // Apellido
                    LyrahTextField(
                        placeholder: "Apellido",
                        text: $lastName,
                        icon: "person.fill"
                    )
                    
                    // Fecha de nacimiento (simplificado)
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                            .frame(width: 24)
                        
                        Text("Fecha de nacimiento")
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        // Para una implementación completa, usar DatePicker
                        Text("Seleccionar")
                            .foregroundColor(.adicionalOne)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.background)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Género (simplificado)
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 24)
                        
                        Text("Género")
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        // Para una implementación completa, usar Picker
                        Text("Seleccionar")
                            .foregroundColor(.adicionalOne)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.background)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal, 24)
                
                // Botón para continuar/guardar
                LyrahButton(
                    title: isOnboarding ? "Comenzar" : "Guardar Cambios",
                    action: {
                        // Aquí iría la lógica para crear/actualizar el perfil
                        // Simulamos que el perfil se creó correctamente
                        authViewModel.onboardingState = .completed
                    },
                    gradientColors: [.primary, .secondary]
                )
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
    }
}

// Vista de previsualización
#Preview {
    OnboardingView()
        .environmentObject(AuthViewModel())
}
