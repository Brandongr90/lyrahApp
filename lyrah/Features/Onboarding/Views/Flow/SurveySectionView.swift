//
//  SurveySectionView.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 25/04/25.
//

import SwiftUI

struct SurveySectionView: View {
    // Preguntas para esta sección
    var questions: [SurveyQuestion]
    // Respuestas actuales (desde el ViewModel)
    var responses: [SurveyResponse]
    // Función para actualizar respuestas
    var onRespond: (SurveyResponse) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(questions) { question in
                QuestionView(
                    question: question,
                    selectedOptionId: getSelectedOptionId(for: question.id),
                    onSelect: { optionId, score in
                        let response = SurveyResponse(
                            questionId: question.id,
                            selectedOptionId: optionId,
                            score: score
                        )
                        onRespond(response)
                    }
                )
                .padding(.bottom, 16)
            }
            Spacer()
        }
        .padding(.vertical, 16)
    }
    
    // Obtener la opción seleccionada para una pregunta
    private func getSelectedOptionId(for questionId: Int) -> Int? {
        return responses.first(where: { $0.questionId == questionId })?.selectedOptionId
    }
}

// Componente para mostrar una pregunta individual
struct QuestionView: View {
    let question: SurveyQuestion
    let selectedOptionId: Int?
    let onSelect: (Int, Int) -> Void // (optionId, score)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Texto de la pregunta
            Text(question.text)
                .font(.montserrat(fontStyle: .headline, fontWeight: .semibold))
                .foregroundColor(.primary)
            
            // Opciones de respuesta
            ForEach(question.options) { option in
                OptionRow(
                    option: option,
                    isSelected: selectedOptionId == option.id,
                    onSelect: {
                        onSelect(option.id, option.score)
                    }
                )
                .padding(.vertical, 2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5)
        )
    }
}

// Componente para mostrar una opción de respuesta
struct OptionRow: View {
    let option: QuestionOption
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(option.text)
                    .font(.montserrat(fontStyle: .body))
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Indicador de selección
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.white : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.adicionalOne : Color.gray.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

//#Preview {
//  SurveySectionView()
//}
