//
//  OnboardingNameView.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 26/03/25.
//

import SwiftUI

struct OnboardingNameView: View {
    // Valores iniciales (pasados desde el View Model)
    var firstName: String
    var lastName: String
    var onUpdate: (String, String) -> Void
    
    // Estado local para edición
    @State private var editFirstName: String
    @State private var editLastName: String
    @State private var isFirstNameValid: Bool = true
    @State private var isLastNameValid: Bool = true
    
    // Inicializador para manejar el estado local
    init(firstName: String, lastName: String, onUpdate: @escaping (String, String) -> Void) {
        self.firstName = firstName
        self.lastName = lastName
        self.onUpdate = onUpdate
        
        // Inicializar el estado local con los valores pasados
        _editFirstName = State(initialValue: firstName)
        _editLastName = State(initialValue: lastName)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Título y descripción
            VStack(alignment: .leading, spacing: 8) {
                Text("¿Cómo te llamas?")
                    .font(.montserrat(fontStyle: .title3, fontWeight: .bold))
                    .foregroundColor(.primary)
                
                Text("Estos datos son para personalizar tu experiencia en Lyrah.")
                    .font(.montserrat(fontStyle: .subheadline))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 8)
            
            // Campo para el nombre
            VStack(alignment: .leading, spacing: 8) {
                Text("Nombre")
                    .font(.montserrat(fontStyle: .footnote, fontWeight: .medium))
                    .foregroundColor(.secondary)
                
                ZStack(alignment: .leading) {
                    LyrahTextField(
                        placeholder: "Tu nombre",
                        text: $editFirstName,
                        icon: "person.fill"
                    )
                    .onChange(of: editFirstName) {
                        isFirstNameValid = validateName(editFirstName)
                        
                        if isFirstNameValid {
                            onUpdate(editFirstName, editLastName)
                        }
                    }
                    
                    
                    // Indicador de error
                    if !isFirstNameValid {
                        Text("Ingresa un nombre válido")
                            .font(.montserrat(fontStyle: .caption))
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(4)
                            .padding(.top, 70) // Ajustar esto según el tamaño de tu LyrahTextField
                    }
                }
            }
            
            // Campo para el apellido
            VStack(alignment: .leading, spacing: 8) {
                Text("Apellido")
                    .font(.montserrat(fontStyle: .footnote, fontWeight: .medium))
                    .foregroundColor(.secondary)
                
                ZStack(alignment: .leading) {
                    LyrahTextField(
                        placeholder: "Tu apellido",
                        text: $editLastName,
                        icon: "person.fill"
                    )
                    .onChange(of: editLastName) {
                        isLastNameValid = validateName(editLastName)
                        
                        if isLastNameValid {
                            onUpdate(editFirstName, editLastName)
                        }
                    }
                    
                    // Indicador de error
                    if !isLastNameValid {
                        Text("Ingresa un apellido válido")
                            .font(.montserrat(fontStyle: .caption))
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(4)
                            .padding(.top, 70) // Ajustar esto según el tamaño de tu LyrahTextField
                    }
                }
            }
            
            // Ayuda o información adicional
            Text("Utilizaremos tu nombre para personalizar la experiencia y comunicarnos contigo.")
                .font(.montserrat(fontStyle: .caption))
                .foregroundColor(.secondary)
                .padding(.top, 12)
            
            Spacer()
        }
        .padding(.vertical, 16)
    }
    
    // Función para validar el nombre/apellido
    private func validateName(_ name: String) -> Bool {
        // Debe tener al menos 2 caracteres y no contener números o caracteres especiales
        // Permitimos acentos y caracteres comunes en nombres latinos
        let nameRegex = "^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: name)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    OnboardingNameView(
        firstName: "",
        lastName: "",
        onUpdate: { _, _ in }
    )
    .padding()
}
