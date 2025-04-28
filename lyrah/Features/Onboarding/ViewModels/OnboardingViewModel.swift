//
//  OnboardingViewModel.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 26/03/25.
//

import Foundation
import SwiftUI
import Combine

// Variable global para almacenar la instancia compartida de AuthViewModel
var sharedAuthViewModel: AuthViewModel?

@MainActor
class OnboardingViewModel: ObservableObject {
    // Datos del onboarding
    @Published var onboardingData = OnboardingData()
    
    // Sección actual y total de secciones
    @Published var currentSection: OnboardingSection = .welcome
    @Published var allSections: [OnboardingSection] = []
    
    // Estado actual del onboarding
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    // Para almacenar temporalmente en UserDefaults
    private let onboardingDataKey = "onboardingData"
    
    // Dependencias de servicios
    private let profileService = ProfileService()
    
    // Instancia estática compartida
    static var shared = OnboardingViewModel()
    
    init() {
        // Configurar las secciones del onboarding
        setupSections()
        
        // Intentar cargar datos guardados
        loadSavedData()
    }
    
    // Configurar todas las secciones del onboarding
    private func setupSections() {
        allSections = [
            .welcome,
            .name,
            .age,
            .gender,
            .improvementAreas
        ]
        
        // Añadir secciones de la encuesta (2-9)
        for section in 2...9 {
            allSections.append(.surveySection(section))
        }
        
        // Añadir sección de consentimiento
        allSections.append(.consent)
    }
    
    // Guardar datos del onboarding localmente
    func saveData() {
        if let encodedData = try? JSONEncoder().encode(onboardingData) {
            UserDefaults.standard.set(encodedData, forKey: onboardingDataKey)
        }
    }
    
    // Cargar datos guardados
    private func loadSavedData() {
        if let savedData = UserDefaults.standard.data(forKey: onboardingDataKey),
           let loadedData = try? JSONDecoder().decode(OnboardingData.self, from: savedData) {
            onboardingData = loadedData
            
            // Encontrar la primera sección incompleta para continuar desde ahí
            if let firstIncomplete = allSections.first(where: { !onboardingData.isSectionCompleted($0) }) {
                currentSection = firstIncomplete
            }
        }
    }
    
    // Avanzar a la siguiente sección
    func moveToNextSection() {
        // Guardar datos actuales
        saveData()
        
        // Encontrar el índice de la sección actual
        if let currentIndex = allSections.firstIndex(of: currentSection),
           currentIndex < allSections.count - 1 {
            // Avanzar a la siguiente sección
            currentSection = allSections[currentIndex + 1]
        } else {
            // Si estamos en la última sección, completar el onboarding
            completeOnboarding()
        }
    }
    
    // Determinar a qué sección pertenece una pregunta por su ID
    func getSectionNumberForQuestion(_ questionId: Int) -> Int {
        // Asignación de preguntas a secciones según el test de Lyrah 3.0
        if questionId >= 1 && questionId <= 4 {
            return 1 // Datos básicos
        } else if questionId >= 5 && questionId <= 7 {
            return 2 // Bienestar Emocional y Mental
        } else if questionId >= 8 && questionId <= 11 {
            return 3 // Bienestar Físico y Vitalidad
        } else if questionId >= 12 && questionId <= 14 {
            return 4 // Conexión Espiritual y Energética
        } else if questionId >= 15 && questionId <= 18 {
            return 5 // Relaciones Personales y Sociales
        } else if questionId >= 19 && questionId <= 20 {
            return 6 // Crecimiento y Desarrollo Personal
        } else if questionId >= 21 && questionId <= 24 {
            return 7 // Salud Financiera y Económica
        } else if questionId >= 25 && questionId <= 26 {
            return 8 // Estabilidad y Satisfacción Profesional
        } else if questionId >= 27 && questionId <= 31 {
            return 9 // Desarrollo Educativo y Personal
        } else {
            return 10 // Consentimiento y Privacidad
        }
    }
    
    // Retroceder a la sección anterior
    func moveToPreviousSection() {
        // Guardar datos actuales
        saveData()
        
        // Encontrar el índice de la sección actual
        if let currentIndex = allSections.firstIndex(of: currentSection),
           currentIndex > 0 {
            // Retroceder a la sección anterior
            currentSection = allSections[currentIndex - 1]
        }
    }
    
    // Calcular el progreso actual (0.0 - 1.0)
    func calculateProgress() -> Float {
        guard let currentIndex = allSections.firstIndex(of: currentSection) else {
            return 0.0
        }
        return Float(currentIndex) / Float(allSections.count - 1)
    }
    
    // Verificar si la sección actual puede avanzar
    func canAdvanceFromCurrentSection() -> Bool {
        switch currentSection {
        case .welcome:
            return true
        case .name:
            return !onboardingData.basicProfile.firstName.isEmpty
        case .age:
            return onboardingData.basicProfile.ageRange != nil
        case .gender:
            return onboardingData.basicProfile.gender != nil
        case .improvementAreas:
            // El usuario debe seleccionar al menos un área de mejora
            return !onboardingData.improvementAreas.isEmpty
        case .surveySection( _):
            // Verificar que todas las preguntas de esta sección estén respondidas
            return onboardingData.isSectionCompleted(currentSection)
        case .consent:
            return onboardingData.consentGiven
        }
    }
    
    // Verificar si estamos en la primera sección
    func isFirstSection() -> Bool {
        return currentSection == allSections.first
    }
    
    // Verificar si estamos en la última sección
    func isLastSection() -> Bool {
        return currentSection == allSections.last
    }
    
    // Completar el onboarding enviando datos a la API
    func completeOnboarding() {
        isLoading = true
        
        // Esta será una función asíncrona que enviará los datos a la API
        Task { [weak self] in
            guard let self else { return }
            
            do {
                // Acceder a la instancia compartida de AuthViewModel
                guard let authViewModel = sharedAuthViewModel else {
                    throw NSError(domain: "Lyrah", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: "No se pudo acceder al AuthViewModel"
                    ])
                }
                
                // 1. Primero crear el perfil básico
                let profileData: [String: Any] = [
                    "user_id": authViewModel.getUserId() ?? "",
                    "first_name": onboardingData.basicProfile.firstName,
                    "last_name": onboardingData.basicProfile.lastName,
                    "gender": onboardingData.basicProfile.gender?.rawValue ?? "No especificado"
                    // Añadir más campos si es necesario
                ]
                
                // Crear el perfil
                try await profileService.createProfile(profileData: profileData)
                
                // 2. Luego obtener el perfil creado para su ID
                if let userId = authViewModel.getUserId(),
                   let _ = try await profileService.getProfile(forUserId: userId) {
                    
                    // 3. Enviar las áreas de mejora
                    if !onboardingData.improvementAreas.isEmpty {
                        // Endpoint para areas de mejora
                        // Por implementar
                    }
                    
                    // 4. Enviar las actividades de bienestar
                    if !onboardingData.wellnessActivities.isEmpty {
                        // Endpoint para actividades de bienestar
                        // Por implementar
                    }
                    
                    // 5. Crear la encuesta con todas las respuestas
                    if !onboardingData.surveyResponses.isEmpty {
                        // Endpoint para crear encuesta
                        // Por implementar
                    }
                    
                    // 6. Limpiar datos locales
                    UserDefaults.standard.removeObject(forKey: onboardingDataKey)
                    
                    // 7. Actualizar estado del usuario
                    
                    self.isLoading = false
                    authViewModel.updateUserHasProfile(true)
                }
            } catch {
                self.isLoading = false
                self.errorMessage = "Error al completar el registro: \(error.localizedDescription)"
                self.showError = true
            }
        }
    }
    
    // Actualizar el nombre del usuario
    func updateName(firstName: String, lastName: String) {
        onboardingData.basicProfile.firstName = firstName
        onboardingData.basicProfile.lastName = lastName
        saveData()
    }
    
    // Actualizar el rango de edad
    func updateAgeRange(_ ageRange: AgeRange) {
        onboardingData.basicProfile.ageRange = ageRange
        saveData()
    }
    
    // Actualizar el género
    func updateGender(_ gender: Gender) {
        onboardingData.basicProfile.gender = gender
        saveData()
    }
    
    // Actualizar las áreas de mejora
    func updateImprovementAreas(_ areas: [ImprovementAreaSelection]) {
        onboardingData.improvementAreas = areas
        saveData()
    }
    
    // Añadir una respuesta a la encuesta
    func addSurveyResponse(questionId: Int, optionId: Int, score: Int) {
        // Verificar si ya existe una respuesta para esta pregunta
        if let index = onboardingData.surveyResponses.firstIndex(where: { $0.questionId == questionId }) {
            // Actualizar la respuesta existente
            onboardingData.surveyResponses[index] = SurveyResponse(
                questionId: questionId,
                selectedOptionId: optionId,
                score: score
            )
        } else {
            // Añadir una nueva respuesta
            onboardingData.surveyResponses.append(
                SurveyResponse(
                    questionId: questionId,
                    selectedOptionId: optionId,
                    score: score
                )
            )
        }
        saveData()
    }
    
    // Actualizar el consentimiento
    func updateConsent(_ consent: Bool) {
        onboardingData.consentGiven = consent
        saveData()
    }
    
    // Añadir este método a OnboardingViewModel
    func getQuestionsForSection(_ sectionNumber: Int) -> [SurveyQuestion] {
        // En un escenario real, estas preguntas se cargarían de la API
        // Por ahora, usaremos preguntas estáticas basadas en el Test Bienvenida Lyrah 3.0
        
        switch sectionNumber {
        case 2: // Bienestar Emocional y Mental
            return [
                createSurveyQuestion(id: 5, text: "¿Cómo describirías tu sueño en el último mes?", sectionNumber: 2, options: [
                    QuestionOption(id: 501, text: "Reparador, duermo bien y despierto con energía", score: 10),
                    QuestionOption(id: 502, text: "Regular, a veces me cuesta dormir o me despierto cansado/a", score: 5),
                    QuestionOption(id: 503, text: "Deficiente, duermo mal o tengo insomnio frecuente", score: 0)
                ]),
                createSurveyQuestion(id: 6, text: "¿Cómo ha sido tu estado de ánimo en el último mes?", sectionNumber: 3, options: [
                    QuestionOption(id: 601, text: "Estable y positivo", score: 10),
                    QuestionOption(id: 602, text: "Con altibajos", score: 5),
                    QuestionOption(id: 603, text: "Predominantemente negativo", score: 0)
                ]),
                createSurveyQuestion(id: 7, text: "¿Cómo percibes tu nivel de energía en el día a día?",sectionNumber: 4, options: [
                    QuestionOption(id: 701, text: "Alta y constante", score: 10),
                    QuestionOption(id: 702, text: "Variable, con momentos de cansancio", score: 5),
                    QuestionOption(id: 703, text: "Baja la mayor parte del tiempo", score: 2),
                    QuestionOption(id: 704, text: "Muy baja, me siento agotado/a constantemente", score: 0)
                ])
            ]
            // Implementar el resto de secciones de manera similar
        case 3: // Bienestar Físico y Vitalidad
            return [
                createSurveyQuestion(id: 8, text: "¿Cómo describirías tu estado de salud y bienestar físico en general?", sectionNumber: 3, options: [
                    QuestionOption(id: 801, text: "Excelente, cuido mi alimentación y me mantengo activo/a", score: 10),
                    QuestionOption(id: 802, text: "Regular, intento mantenerme saludable pero no siempre lo logro", score: 5),
                    QuestionOption(id: 803, text: "Deficiente, me gustaría mejorar mis hábitos de salud", score: 0)
                ]),
                createSurveyQuestion(id: 9, text: "¿Cuántas horas duermes en promedio?", sectionNumber: 3, options: [
                    QuestionOption(id: 901, text: "Menos de 5 horas", score: 0),
                    QuestionOption(id: 902, text: "Entre 5 y 6 horas", score: 5),
                    QuestionOption(id: 903, text: "Entre 7 y 8 horas", score: 7),
                    QuestionOption(id: 904, text: "Entre 9 y 10 horas", score: 8),
                    QuestionOption(id: 905, text: "Más de 10 horas", score: 10)
                ]),
                createSurveyQuestion(id: 10, text: "¿Con qué frecuencia realizas actividad física moderada o intensa?", sectionNumber: 3, options: [
                    QuestionOption(id: 1001, text: "Todos los días o casi todos los días", score: 10),
                    QuestionOption(id: 1002, text: "3-5 veces por semana", score: 7),
                    QuestionOption(id: 1003, text: "1-2 veces por semana", score: 5),
                    QuestionOption(id: 1004, text: "Rara vez o nunca", score: 0)
                ]),
                createSurveyQuestion(id: 11, text: "¿Cómo describirías tu alimentación en general?", sectionNumber: 3, options: [
                    QuestionOption(id: 1101, text: "Equilibrada y nutritiva", score: 10),
                    QuestionOption(id: 1102, text: "Regular, trato de comer saludable pero tengo hábitos que mejorar", score: 5),
                    QuestionOption(id: 1103, text: "Poco saludable, tengo malos hábitos alimenticios", score: 0)
                ])
            ]
        case 4: // Conexión Espiritual y Energética
            return [
                createSurveyQuestion(id: 12, text: "¿Cómo describirías tu conexión espiritual o sentido de propósito?", sectionNumber: 4, options: [
                    QuestionOption(id: 1201, text: "Fuerte, siento que tengo un propósito claro en la vida", score: 10),
                    QuestionOption(id: 1202, text: "Intermedia, busco respuestas pero aún no las encuentro completamente", score: 5),
                    QuestionOption(id: 1203, text: "Débil o nula, no suelo enfocarme en estos temas", score: 0)
                ]),
                createSurveyQuestion(id: 13, text: "¿Practicas la gratitud de manera consciente en tu vida?", sectionNumber: 4, options: [
                    QuestionOption(id: 1301, text: "Sí, todos los días o casi todos los días", score: 10),
                    QuestionOption(id: 1302, text: "Ocasionalmente, pero no con regularidad", score: 5),
                    QuestionOption(id: 1303, text: "No, casi nunca o nunca", score: 0)
                ]),
                createSurveyQuestion(id: 14, text: "¿Sientes que tu vida tiene un propósito claro?", sectionNumber: 4, options: [
                    QuestionOption(id: 1401, text: "Sí, tengo claridad sobre mi propósito", score: 10),
                    QuestionOption(id: 1402, text: "Más o menos, aún lo estoy explorando", score: 5),
                    QuestionOption(id: 1403, text: "No, no siento que tenga un propósito definido", score: 0)
                ])
            ]
        case 5: // Relaciones Personales y Sociales
            return [
                createSurveyQuestion(id: 15, text: "¿Cómo percibes tus relaciones personales? (Amistades y entorno social)", sectionNumber: 5, options: [
                    QuestionOption(id: 1501, text: "Satisfactorias, tengo relaciones sólidas y enriquecedoras", score: 10),
                    QuestionOption(id: 1502, text: "Neutras, me gustaría fortalecer mis amistades", score: 5),
                    QuestionOption(id: 1503, text: "Distantes, siento que me cuesta conectar con los demás", score: 0)
                ]),
                createSurveyQuestion(id: 16, text: "¿Cómo percibes tus relaciones amorosas?", sectionNumber: 5, options: [
                    QuestionOption(id: 1601, text: "Plenas, mi relación me aporta bienestar y crecimiento", score: 10),
                    QuestionOption(id: 1602, text: "Estables, pero con áreas que podrían mejorar", score: 5),
                    QuestionOption(id: 1603, text: "En búsqueda o en proceso de mejora personal en este aspecto", score: 0)
                ]),
                createSurveyQuestion(id: 17, text: "¿Qué tan a menudo te sientes apoyado/a por tus amigos o familiares?", sectionNumber: 5, options: [
                    QuestionOption(id: 1701, text: "Siempre, tengo una red de apoyo sólida", score: 10),
                    QuestionOption(id: 1702, text: "A veces, pero me gustaría mejorar mis relaciones", score: 5),
                    QuestionOption(id: 1703, text: "Rara vez o nunca, me siento solo/a", score: 0)
                ]),
                createSurveyQuestion(id: 18, text: "¿Qué tan efectiva es tu comunicación en tus relaciones?", sectionNumber: 5, options: [
                    QuestionOption(id: 1801, text: "Buena, sé expresar mis ideas y emociones", score: 10),
                    QuestionOption(id: 1802, text: "Regular, a veces me cuesta comunicarme bien", score: 5),
                    QuestionOption(id: 1803, text: "Deficiente, me cuesta mucho expresar lo que siento", score: 0)
                ])
            ]
        case 6: // Crecimiento y Desarrollo Personal
            return [
                createSurveyQuestion(id: 19, text: "¿Te sientes alineado/a con tus objetivos y crecimiento personal?", sectionNumber: 6, options: [
                    QuestionOption(id: 1901, text: "Totalmente alineado/a, con claridad en mis metas", score: 10),
                    QuestionOption(id: 1902, text: "Tengo algunas ideas, pero aún no defino mi camino", score: 5),
                    QuestionOption(id: 1903, text: "Me gustaría encontrar más claridad y enfoque", score: 0)
                ]),
                createSurveyQuestion(id: 20, text: "¿Qué tan seguido adquieres nuevas habilidades o conocimientos para tu desarrollo profesional?", sectionNumber: 6, options: [
                    QuestionOption(id: 2001, text: "Constantemente, invierto en cursos y aprendizaje", score: 10),
                    QuestionOption(id: 2002, text: "De vez en cuando, pero no con frecuencia", score: 5),
                    QuestionOption(id: 2003, text: "No lo hago, no me actualizo en mi área", score: 0)
                ])
            ]
            
        case 7: // Salud Financiera y Económica
            return [
                createSurveyQuestion(id: 21, text: "¿Cómo sientes tu situación financiera actual?", sectionNumber: 7, options: [
                    QuestionOption(id: 2101, text: "Satisfactoria y estable", score: 10),
                    QuestionOption(id: 2102, text: "Neutra, podría mejorar", score: 5),
                    QuestionOption(id: 2103, text: "Inestable o preocupante", score: 0)
                ]),
                createSurveyQuestion(id: 22, text: "¿Qué tanto control sientes que tienes sobre tus finanzas?", sectionNumber: 7, options: [
                    QuestionOption(id: 2201, text: "Totalmente organizado/a", score: 10),
                    QuestionOption(id: 2202, text: "Algo de control, pero con áreas de mejora", score: 5),
                    QuestionOption(id: 2203, text: "Me gustaría aprender a gestionarlas mejor", score: 0)
                ]),
                createSurveyQuestion(id: 23, text: "¿Tienes un fondo de ahorro para emergencias?", sectionNumber: 7, options: [
                    QuestionOption(id: 2301, text: "Sí, cubre al menos 6 meses de mis gastos", score: 10),
                    QuestionOption(id: 2302, text: "Sí, pero es menor a 6 meses de gastos", score: 5),
                    QuestionOption(id: 2303, text: "No tengo un fondo de ahorro", score: 0)
                ]),
                createSurveyQuestion(id: 24, text: "¿Cómo manejas tus deudas y compromisos financieros?", sectionNumber: 7, options: [
                    QuestionOption(id: 2401, text: "No tengo deudas o las manejo bien sin problemas", score: 10),
                    QuestionOption(id: 2402, text: "Tengo algunas deudas, pero las controlo moderadamente", score: 5),
                    QuestionOption(id: 2403, text: "Tengo muchas deudas y me cuesta administrarlas", score: 0)
                ])
            ]
        case 8: // Estabilidad y Satisfacción Profesional
            return [
                createSurveyQuestion(id: 25, text: "¿Cómo percibes tu estabilidad laboral y profesional?", sectionNumber: 8, options: [
                    QuestionOption(id: 2501, text: "Estable y en crecimiento", score: 10),
                    QuestionOption(id: 2502, text: "Neutra, sin cambios significativos", score: 5),
                    QuestionOption(id: 2503, text: "En transición o explorando nuevas oportunidades", score: 0)
                ]),
                createSurveyQuestion(id: 26, text: "¿Te sientes satisfecho/a con tu trabajo o actividad actual?", sectionNumber: 8, options: [
                    QuestionOption(id: 2601, text: "Sí, me gusta lo que hago y veo crecimiento", score: 10),
                    QuestionOption(id: 2602, text: "Es neutral, pero no me desagrada", score: 5),
                    QuestionOption(id: 2603, text: "No me gusta, me gustaría cambiar de trabajo o actividad", score: 0)
                ])
            ]
        case 9: // Desarrollo Educativo y Personal
            return [
                createSurveyQuestion(id: 27, text: "¿Cuánto tiempo dedicas a actividades recreativas o hobbies?", sectionNumber: 9, options: [
                    QuestionOption(id: 2701, text: "Varias veces por semana", score: 10),
                    QuestionOption(id: 2702, text: "Ocasionalmente, pero no con frecuencia", score: 5),
                    QuestionOption(id: 2703, text: "Casi nunca o nunca", score: 0)
                ]),
                createSurveyQuestion(id: 28, text: "¿Te permites momentos de descanso y disfrute sin sentirte culpable?", sectionNumber: 9, options: [
                    QuestionOption(id: 2801, text: "Sí, sé equilibrar el trabajo y el ocio", score: 10),
                    QuestionOption(id: 2802, text: "A veces, pero me cuesta desconectarme", score: 5),
                    QuestionOption(id: 2803, text: "No, siento que siempre estoy ocupado/a", score: 0)
                ]),
                createSurveyQuestion(id: 29, text: "¿Cómo calificas el entorno en el que vives (hogar, vecindario, ciudad)?", sectionNumber: 9, options: [
                    QuestionOption(id: 2901, text: "Cómodo y agradable", score: 10),
                    QuestionOption(id: 2902, text: "Aceptable, pero hay cosas que mejorar", score: 5),
                    QuestionOption(id: 2903, text: "Incómodo o poco satisfactorio", score: 0)
                ]),
                createSurveyQuestion(id: 30, text: "¿Qué tan ordenado/a te sientes en tu vida diaria?", sectionNumber: 9, options: [
                    QuestionOption(id: 3001, text: "Muy ordenado/a, tengo hábitos organizados", score: 10),
                    QuestionOption(id: 3002, text: "Más o menos, pero a veces me desorganizo", score: 5),
                    QuestionOption(id: 3003, text: "Nada ordenado/a, me cuesta gestionar mis cosas", score: 0)
                ]),
                createSurveyQuestion(id: 31, text: "¿Cómo manejas el equilibrio entre vida personal y responsabilidades?", sectionNumber: 9, options: [
                    QuestionOption(id: 3101, text: "Tengo un buen balance entre trabajo, descanso y vida personal", score: 10),
                    QuestionOption(id: 3102, text: "A veces me cuesta desconectarme del trabajo o las responsabilidades", score: 5),
                    QuestionOption(id: 3103, text: "Me siento sobrecargado/a y sin suficiente tiempo para mí", score: 0)
                ])
            ]
        default:
            return []
        }
    }
    
    // Función auxiliar para crear preguntas
    private func createSurveyQuestion(id: Int, text: String, sectionNumber: Int, options: [QuestionOption]) -> SurveyQuestion {
        return SurveyQuestion(
            id: id,
            text: text,
            sectionNumber: sectionNumber,
            questionNumber: id,
            options: options
        )
    }
    
    // Verificar si hay datos parciales en la sección actual
    func hasPartialDataInCurrentSection() -> Bool {
        switch currentSection {
        case .name:
            return !onboardingData.basicProfile.firstName.isEmpty || !onboardingData.basicProfile.lastName.isEmpty
        case .age:
            // Comprobamos si ha seleccionado algo, pero no ha completado totalmente
            return onboardingData.basicProfile.ageRange != nil
        case .gender:
            return onboardingData.basicProfile.gender != nil
        case .improvementAreas:
            return !onboardingData.improvementAreas.isEmpty
        case .surveySection(let sectionNumber):
            // Verificar si hay al menos una respuesta para esta sección
            return onboardingData.surveyResponses.contains { response in
                getSectionNumberForQuestion(response.questionId) == sectionNumber
            }
        case .consent:
            return false // No tiene sentido verificar datos parciales en consentimiento
        default:
            return false
        }
    }
}

// Extensión para AuthViewModel con métodos auxiliares
extension AuthViewModel {
    // Obtener el ID del usuario actual
    func getUserId() -> String? {
        if case .authenticated(let user) = authState {
            return user.id
        }
        return nil
    }
    
    // Actualizar el estado del perfil del usuario
    func updateUserHasProfile(_ hasProfile: Bool) {
        if case .authenticated(var user) = authState {
            user.hasProfile = hasProfile
            self.authState = .authenticated(user)
            
            // También actualizar el estado de onboarding
            if hasProfile {
                self.onboardingState = .completed
            }
        }
    }
}
