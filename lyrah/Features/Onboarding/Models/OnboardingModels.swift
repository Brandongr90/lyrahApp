//
//  OnboardingModels.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 26/03/25.
//

import Foundation

// Modelo para almacenar todos los datos de onboarding
struct OnboardingData: Codable {
    // Datos básicos del perfil (primeras pantallas)
    var basicProfile = BasicProfileData()
    
    // Áreas de mejora seleccionadas por el usuario
    var improvementAreas: [ImprovementAreaSelection] = []
    
    // Actividades de bienestar seleccionadas
    var wellnessActivities: [Int] = []
    
    // Respuestas a las preguntas de la encuesta
    var surveyResponses: [SurveyResponse] = []
    
    // Consentimiento para el uso de datos
    var consentGiven: Bool = false
    
    // Para verificar si se ha completado una sección específica
    func isSectionCompleted(_ section: OnboardingSection) -> Bool {
        switch section {
        case .welcome:
            return true // Siempre está completa
        case .name:
            return !basicProfile.firstName.isEmpty
        case .age:
            return basicProfile.ageRange != nil
        case .gender:
            return basicProfile.gender != nil
        case .improvementAreas:
            return !improvementAreas.isEmpty
        case .surveySection(let sectionNumber):
            // Verificar si todas las preguntas de esta sección han sido respondidas
            let sectionResponses = surveyResponses.filter {
                getSectionNumberForQuestion($0.questionId) == sectionNumber
            }
            // Comparar con el número total de preguntas en esta sección
            return sectionResponses.count == getQuestionCountForSection(sectionNumber)
        case .consent:
            return consentGiven
        }
    }
    
    // Función auxiliar para obtener el número de sección de una pregunta
    private func getSectionNumberForQuestion(_ questionId: Int) -> Int {
        // Implementación basada en la estructura del cuestionario
        // Por ahora, simplificado
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
    
    // Función auxiliar para obtener el número de preguntas por sección
    private func getQuestionCountForSection(_ sectionNumber: Int) -> Int {
        switch sectionNumber {
        case 1: return 4  // Datos básicos
        case 2: return 3  // Bienestar Emocional y Mental
        case 3: return 4  // Bienestar Físico y Vitalidad
        case 4: return 3  // Conexión Espiritual y Energética
        case 5: return 4  // Relaciones Personales y Sociales
        case 6: return 2  // Crecimiento y Desarrollo Personal
        case 7: return 4  // Salud Financiera y Económica
        case 8: return 2  // Estabilidad y Satisfacción Profesional
        case 9: return 5  // Desarrollo Educativo y Personal
        case 10: return 1 // Consentimiento y Privacidad
        default: return 0
        }
    }
}

// Datos básicos del perfil (primeras pantallas)
struct BasicProfileData: Codable {
    var firstName: String = ""
    var lastName: String = ""
    var ageRange: AgeRange? = nil
    var gender: Gender? = nil
}

// Rangos de edad definidos en el cuestionario
enum AgeRange: String, CaseIterable, Codable {
    case under18 = "Menos de 18 años"
    case age18to24 = "18 - 24 años"
    case age25to34 = "25 - 34 años"
    case age35to44 = "35 - 44 años"
    case age45to54 = "45 - 54 años"
    case age55to64 = "55 - 64 años"
    case age65Plus = "65 años o más"
}

// Opciones de género definidas en el cuestionario
enum Gender: String, CaseIterable, Codable {
    case male = "Masculino"
    case female = "Femenino"
    case neutral = "Neutro"
    case preferNotToSay = "Prefiero no decirlo"
}

// Representa una selección de área de mejora con su prioridad
struct ImprovementAreaSelection: Codable, Identifiable {
    var id: Int
    var name: String
    var description: String
    var priorityOrder: Int
    
    // Para facilitar la creación desde los datos de la API
    init(optionId: Int, name: String, description: String, priorityOrder: Int) {
        self.id = optionId
        self.name = name
        self.description = description
        self.priorityOrder = priorityOrder
    }
}

// Modelo para las áreas de mejora disponibles
struct ImprovementAreaOption: Codable, Identifiable {
    var id: Int
    var name: String
    var description: String
    
    enum CodingKeys: String, CodingKey {
        case id = "option_id"
        case name
        case description
    }
}

// Modelo para actividades de bienestar
struct WellnessActivityOption: Codable, Identifiable {
    var id: Int
    var name: String
    var description: String
    
    enum CodingKeys: String, CodingKey {
        case id = "option_id"
        case name
        case description
    }
}

// Modelo para representar una respuesta a una pregunta de la encuesta
struct SurveyResponse: Codable, Identifiable {
    var id = UUID()
    var questionId: Int
    var selectedOptionId: Int
    var score: Int
    
    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case selectedOptionId = "selected_option_id"
        case score
    }
}

// Modelo para representar una pregunta de la encuesta
struct SurveyQuestion: Codable, Identifiable {
    var id: Int
    var text: String
    var sectionNumber: Int
    var questionNumber: Int
    var options: [QuestionOption]
    
    enum CodingKeys: String, CodingKey {
        case id = "question_id"
        case text = "question_text"
        case sectionNumber = "section_number"
        case questionNumber = "question_number"
        case options
    }
}

// Modelo para representar una opción de respuesta
struct QuestionOption: Codable, Identifiable {
    var id: Int
    var text: String
    var score: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "option_id"
        case text = "option_text"
        case score
    }
}

// Enum para representar las secciones del onboarding
enum OnboardingSection: Equatable {
    case welcome
    case name
    case age
    case gender
    case improvementAreas
    case surveySection(Int) // Para las secciones de la encuesta (2-9)
    case consent
    
    // Título para mostrar en la UI
    var title: String {
        switch self {
        case .welcome:
            return "Bienvenido a Lyrah"
        case .name:
            return "Sobre ti"
        case .age:
            return "Tu edad"
        case .gender:
            return "Tu género"
        case .improvementAreas:
            return "Áreas de mejora"
        case .surveySection(let number):
            switch number {
            case 2:
                return "Bienestar Emocional y Mental"
            case 3:
                return "Bienestar Físico y Vitalidad"
            case 4:
                return "Conexión Espiritual y Energética"
            case 5:
                return "Relaciones Personales y Sociales"
            case 6:
                return "Crecimiento y Desarrollo Personal"
            case 7:
                return "Salud Financiera y Económica"
            case 8:
                return "Estabilidad y Satisfacción Profesional"
            case 9:
                return "Desarrollo Educativo y Personal"
            default:
                return "Sección \(number)"
            }
        case .consent:
            return "Consentimiento y Privacidad"
        }
    }
}
