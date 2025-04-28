//
//  OnboardingRegisterGeneralView.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 26/03/25.
//

import SwiftUI

struct OnboardingRegisterGeneralView: View {
    @StateObject private var viewModel = OnboardingViewModel.shared
    @State private var showingConfirmationAlert = false
    
    var body: some View {
        ZStack {
            // Fondo
            LinearGradient(gradient: Gradient(colors: [.background, .white]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Barra de progreso en la parte superior
                OnboardingProgressView(
                    progress: viewModel.calculateProgress(),
                    title: viewModel.currentSection.title
                )
                .padding(.top, 12)
                
                // Contenido principal (contenido variable según la sección)
                ScrollView {
                    VStack(spacing: 20) {
                        // Contenido específico para cada sección
                        sectionContent
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                    }
                    .frame(maxWidth: .infinity)
                }
                .refreshable {} // Para habilitar el gesto de pull-to-refresh
                
                // Botones de navegación
                navigationButtons
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.9))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: -4)
            }
            
            // Indicador de carga
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .overlay(
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                    )
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("Aceptar"))
            )
        }
        .alert(isPresented: $showingConfirmationAlert) {
            Alert(
                title: Text("¿Estás seguro?"),
                message: Text("Si sales ahora, perderás tu progreso en esta sección."),
                primaryButton: .destructive(Text("Salir")) {
                    viewModel.moveToPreviousSection()
                },
                secondaryButton: .cancel(Text("Continuar"))
            )
        }
    }
    
    // Vista variable según la sección actual
    @ViewBuilder
    private var sectionContent: some View {
        switch viewModel.currentSection {
        case .welcome:
            OnboardingWelcomeView()
        case .name:
            OnboardingNameView(
                firstName: viewModel.onboardingData.basicProfile.firstName,
                lastName: viewModel.onboardingData.basicProfile.lastName,
                onUpdate: { firstName, lastName in
                    viewModel.updateName(firstName: firstName, lastName: lastName)
                }
            )
        case .age:
            OnboardingAgeView(
                selectedRange: viewModel.onboardingData.basicProfile.ageRange,
                onSelect: { ageRange in
                    viewModel.updateAgeRange(ageRange)
                }
            )
        case .gender:
            OnboardingGenderView(
                selectedGender: viewModel.onboardingData.basicProfile.gender,
                onSelect: { gender in
                    viewModel.updateGender(gender)
                }
            )
        case .improvementAreas:
            OnboardingImprovementAreasView(
                selectedAreas: viewModel.onboardingData.improvementAreas,
                onUpdate: { areas in
                    viewModel.updateImprovementAreas(areas)
                }
            )
        case .surveySection(let sectionNumber):
            // Obtener las preguntas para esta sección específica
            let sectionQuestions = viewModel.getQuestionsForSection(sectionNumber)
            SurveySectionView(
                questions: sectionQuestions,
                responses: viewModel.onboardingData.surveyResponses,
                onRespond: { response in
                    viewModel.addSurveyResponse(
                        questionId: response.questionId,
                        optionId: response.selectedOptionId,
                        score: response.score
                    )
                }
            )
        case .consent:
            OnboardingConsentView(
                consentGiven: viewModel.onboardingData.consentGiven,
                onUpdate: { consent in
                    viewModel.updateConsent(consent)
                }
            )
            
        }
    }
    
    // Botones de navegación
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Botón Atrás (excepto en la primera sección)
            if !viewModel.isFirstSection() {
                Button(action: {
                    // Solo mostrar alerta si hay información parcial pero no completa
                    if viewModel.hasPartialDataInCurrentSection() &&
                        !viewModel.canAdvanceFromCurrentSection() {
                        showingConfirmationAlert = true
                    } else {
                        viewModel.moveToPreviousSection()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Atrás")
                    }
                    .foregroundColor(.adicionalOne)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.adicionalOne, lineWidth: 1)
                    )
                }
            } else {
                // Espaciador para mantener la alineación cuando no hay botón atrás
                Spacer()
                    .frame(height: 44)
            }
            
            Spacer()
            
            // Botón Siguiente o Finalizar
            LyrahButton(
                title: viewModel.isLastSection() ? "Finalizar" : "Siguiente",
                action: {
                    viewModel.moveToNextSection()
                },
                gradientColors: [.adicionalOne, .adicionalTwo],
                isLoading: viewModel.isLoading
            )
            .frame(minWidth: 120)
            .disabled(!viewModel.canAdvanceFromCurrentSection())
            .opacity(viewModel.canAdvanceFromCurrentSection() ? 1.0 : 0.6)
        }
    }
}

// Vista de bienvenida
struct OnboardingWelcomeView: View {
    var body: some View {
        VStack(spacing: 30) {
            // Logo
            LyrahLogo(size: 120)
                .padding(.top, 20)
            
            // Título
            Text("Bienvenido a Lyrah")
                .font(.montserrat(fontStyle: .title, fontWeight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            // Descripción
            Text("Vamos a configurar tu perfil para personalizar tu experiencia y ayudarte a encontrar tu espacio de bienestar.")
                .font(.montserrat(fontStyle: .body))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Imagen ilustrativa
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.adicionalOne)
                .padding(.vertical, 30)
            
            Spacer()
        }
    }
}

//#Preview {
//    OnboardingRegisterGeneralView()
//}
