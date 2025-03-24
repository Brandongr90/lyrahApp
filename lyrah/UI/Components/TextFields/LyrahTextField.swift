//
//  LyrahTextField.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 24/03/25.
//

import SwiftUI

// Campo de texto estilizado para los formularios
struct LyrahTextField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String? // Nombre del SF Symbol
    var isSecure: Bool = false
    
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            // Icono si existe
            if let iconName = icon {
                Image(systemName: iconName)
                    .foregroundColor(isEditing ? Color.adicionalTwo : Color.secondary)
                    .frame(width: 24)
            }
            
            // Campo de texto
            if isSecure {
                SecureField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                TextField(placeholder, text: $text, onEditingChanged: { editing in
                    isEditing = editing
                })
                .autocapitalization(.none)
                .disableAutocorrection(true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isEditing ? Color.adicionalTwo : Color.clear, lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
