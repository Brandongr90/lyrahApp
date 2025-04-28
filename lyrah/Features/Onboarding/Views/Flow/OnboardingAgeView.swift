//
//  OnboardingAgeView.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 26/03/25.
//

import SwiftUI

struct OnboardingAgeView: View {
    // Valor inicial (pasado desde el View Model)
    var selectedRange: AgeRange?
    var onSelect: (AgeRange) -> Void
    
    // Estado local para la selección
    @State private var localSelectedRange: AgeRange?
    
    // Inicializador para manejar el estado local
    init(selectedRange: AgeRange?, onSelect: @escaping (AgeRange) -> Void) {
        self.selectedRange = selectedRange
        self.onSelect = onSelect
        _localSelectedRange = State(initialValue: selectedRange)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Título y descripción
            VStack(alignment: .leading, spacing: 8) {
                Text("¿Cuál es tu rango de edad?")
                    .font(.montserrat(fontStyle: .title3, fontWeight: .bold))
                    .foregroundColor(.primary)
                
                Text("Esta información nos ayuda a entender mejor tus necesidades.")
                    .font(.montserrat(fontStyle: .subheadline))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 8)
            
            // Opciones de rango de edad
            VStack(spacing: 16) {
                ForEach(AgeRange.allCases, id: \.self) { ageRange in
                    AgeRangeOptionButton(
                        ageRange: ageRange,
                        isSelected: localSelectedRange == ageRange,
                        onTap: {
                            localSelectedRange = ageRange
                            onSelect(ageRange)
                        }
                    )
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 16)
    }
}

// Componente para cada opción de rango de edad
struct AgeRangeOptionButton: View {
    let ageRange: AgeRange
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(ageRange.rawValue)
                    .font(.montserrat(fontStyle: .body))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.adicionalOne : Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    OnboardingAgeView(
        selectedRange: nil,
        onSelect: { _ in }
    )
    .padding()
}
