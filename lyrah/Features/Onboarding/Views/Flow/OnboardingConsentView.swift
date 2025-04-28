//
//  OnboardingConsentView.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 25/04/25.
//

import SwiftUI

struct OnboardingConsentView: View {
    // Estado actual del consentimiento
    var consentGiven: Bool
    // Funcion para actualizar el consentimineto
    var onUpdate: (Bool) -> Void
    
    // Estado local
    @State private var localConsent: Bool
    
    init(consentGiven: Bool, onUpdate: @escaping (Bool) -> Void) {
        self.consentGiven = consentGiven
        self.onUpdate = onUpdate
        _localConsent = State(initialValue: consentGiven)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Título y descripción
            VStack(alignment: .leading, spacing: 8) {
                Text("Consentimiento y Privacidad")
                    .font(.montserrat(fontStyle: .title3, fontWeight: .bold))
                    .foregroundColor(.primary)
                
                Text("Antes de finalizar, necesitamos tu consentimiento para el uso de tus datos.")
                    .font(.montserrat(fontStyle: .subheadline))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 8)
            
            // Información de privacidad
            VStack(alignment: .leading, spacing: 16) {
                Text("Política de Privacidad")
                    .font(.montserrat(fontStyle: .headline, fontWeight: .semibold))
                    .foregroundColor(.primary)
                
                Text("En Lyrah, valoramos tu privacidad y protegemos tus datos personales. La información que compartes con nosotros se utiliza únicamente para personalizar tu experiencia y brindarte recomendaciones precisas para mejorar tu bienestar.")
                    .font(.montserrat(fontStyle: .body))
                    .foregroundColor(.secondary)
                
                Text("Tus datos están seguros y no se comparten con terceros sin tu consentimiento explícito.")
                    .font(.montserrat(fontStyle: .body))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                // Checkbox de consentimiento
                Button(action: {
                    localConsent.toggle()
                    onUpdate(localConsent)
                }) {
                    HStack(alignment: .top, spacing: 12) {
                        // Checkbox
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(localConsent ? Color.adicionalOne : Color.gray, lineWidth: 2)
                                .frame(width: 24, height: 24)
                            
                            if localConsent {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.adicionalOne)
                                    .frame(width: 24, height: 24)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Texto del consentimiento
                        Text("Acepto la Política de Privacidad y autorizo el uso de mis datos conforme a las normativas vigentes.")
                            .font(.montserrat(fontStyle: .body))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
            )
            
            Spacer()
        }
        .padding(.vertical, 16)
    }
}

//#Preview {
//    OnboardingConsentView()
//}
