//
//  OnboardingGenderView.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 26/03/25.
//

import SwiftUI

struct OnboardingGenderView: View {
    // Valor inicial (pasado desde el View Model)
    var selectedGender: Gender?
    var onSelect: (Gender) -> Void
    
    // Estado local para la selección
    @State private var localSelectedGender: Gender?
    
    // Iconos para cada género
    private let genderIcons: [Gender: String] = [
        .male: "person",
        .female: "person",
        .neutral: "person.fill.questionmark",
        .preferNotToSay: "person.fill.xmark"
    ]
    
    // Inicializador para manejar el estado local
    init(selectedGender: Gender?, onSelect: @escaping (Gender) -> Void) {
        self.selectedGender = selectedGender
        self.onSelect = onSelect
        _localSelectedGender = State(initialValue: selectedGender)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Título y descripción
            VStack(alignment: .leading, spacing: 8) {
                Text("¿Con qué género te identificas?")
                    .font(.montserrat(fontStyle: .title3, fontWeight: .bold))
                    .foregroundColor(.primary)
                
                Text("Selecciona la opción que mejor te represente.")
                    .font(.montserrat(fontStyle: .subheadline))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 8)
            
            // Opciones de género
            VStack(spacing: 16) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    GenderOptionButton(
                        gender: gender,
                        iconName: genderIcons[gender] ?? "person",
                        isSelected: localSelectedGender == gender,
                        onTap: {
                            localSelectedGender = gender
                            onSelect(gender)
                        }
                    )
                }
            }
            
            // Nota informativa
            Text("Esta información es confidencial y solo se utiliza para personalizar tu experiencia.")
                .font(.montserrat(fontStyle: .caption))
                .foregroundColor(.secondary)
                .padding(.top, 12)
            
            Spacer()
        }
        .padding(.vertical, 16)
    }
}

// Componente para cada opción de género
struct GenderOptionButton: View {
    let gender: Gender
    let iconName: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Icono
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.adicionalOne.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? Color.adicionalOne : Color.gray)
                }
                
                // Texto
                Text(gender.rawValue)
                    .font(.montserrat(fontStyle: .body))
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .padding(.leading, 12)
                
                Spacer()
                
                // Indicador de selección
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.adicionalOne : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.adicionalOne)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.adicionalOne : Color.clear, lineWidth: 2)
            )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    OnboardingGenderView(
        selectedGender: nil,
        onSelect: { _ in }
    )
    .padding()
}
