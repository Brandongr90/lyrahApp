//
//  ColorExtensions.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 11/03/25.
//

import SwiftUI

extension Color {
    static let primary = Color("primaryPurple")     // #210d3b - Deep purple
    static let secondary = Color("secondaryBlue") // #38409e - Deep blue
    static let adicionalone = Color("AdicionalOne") // #3887bf - Medium blue
    static let adicionaltwo = Color("AdicionalTwo") // #3dc2ed - Light blue
    
    // Añadimos algunos colores de utilidad
    static let background = Color.primary.opacity(0.05)
    static let textLight = Color.white
    static let textDark = Color.primary
}

// Extensión para crear gradientes fácilmente
extension LinearGradient {
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [Color.primary, Color.secondary]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let blueGradient = LinearGradient(
        gradient: Gradient(colors: [Color.adicionalOne, Color.adicionalTwo]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
