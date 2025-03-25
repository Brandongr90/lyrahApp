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
    var hasProfile: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case username
        case email
        case isActive = "is_active"
        case isVerified = "is_verified"
    }
    
    // Añadir init desde Decoder para manejar campos faltantes
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        isVerified = try container.decode(Bool.self, forKey: .isVerified)
        // hasProfile no se decodifica, usamos el valor por defecto
    }
    
    // Constructor manual para crear desde LoginUser
    init(id: String, username: String, email: String, isActive: Bool, isVerified: Bool, hasProfile: Bool) {
        self.id = id
        self.username = username
        self.email = email
        self.isActive = isActive
        self.isVerified = isVerified
        self.hasProfile = hasProfile
    }
}

struct LoginCredentials {
    var username: String = ""
    var email: String = ""
    var password: String = ""
    // Podemos usar email o username para login
}

struct LoginResponse: Decodable {
    let success: Bool
    let message: String?
    let data: LoginData?
    let error: String?
}

struct RegisterResponse: Codable {
    let success: Bool
    let message: String?
    let data: User?
    let error: String?
}

struct LoginUser: Codable {
    let id: String
    let username: String
    let email: String
    let roleName: String
    let isVerified: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case username
        case email
        case roleName = "role_name"
        case isVerified = "is_verified"
    }
    
    // Metodo para convertir a User
    func toUser() -> User {
        return User(
            id: id,
            username: username,
            email: email,
            isActive: true,
            isVerified: isVerified,
            hasProfile: false
        )
    }
}

// Actualizar LoginData
struct LoginData: Decodable {
    let user: LoginUser
    let token: String
}
