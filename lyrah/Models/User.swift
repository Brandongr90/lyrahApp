//
//  User.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 11/03/25.
//

import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: String
    let username: String
    let email: String
    let isActive: Bool
    let isVerified: Bool
    var hasProfile: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case username
        case email
        case isActive = "is_active"
        case isVerified = "is_verified"
        case hasProfile = "has_profile"  // Este campo lo añadiremos manualmente según la API
    }
}

struct LoginCredentials {
    var username: String = ""
    var email: String = ""
    var password: String = ""
    // Podemos usar email o username para login
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String?
    let data: User?
    let token: String?
    
    // Estructuras adicionales para manejar errores
    let error: String?
}

struct RegisterResponse: Codable {
    let success: Bool
    let message: String?
    let data: User?
    let error: String?
}
