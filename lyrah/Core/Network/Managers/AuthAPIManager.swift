//
//  AuthAPIManager.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 24/03/25.
//

import Foundation

class AuthAPIManager {
    private let networkConfig: NetworkConfig
    
    init(networkConfig: NetworkConfig = .default) {
        self.networkConfig = networkConfig
    }
    
    struct LoginResponse: Decodable {
        let success: Bool
        let message: String?
        let data: User?
        let token: String?
        let error: String?
    }
    
    struct RegisterResponse: Decodable {
        let success: Bool
        let message: String?
        let data: User?
        let error: String?
    }
    
    func login(email: String? = nil, username: String? = nil, password: String) async throws -> (User, String) {
        var body: [String: Any] = ["password": password]
        
        if let email = email, !email.isEmpty {
            body["email"] = email
        } else if let username = username, !username.isEmpty {
            body["username"] = username
        } else {
            throw APIError.serverError("Se requiere email o username")
        }
        
        let response: LoginResponse = try await networkConfig.request(
            endpoint: AuthEndpoint.login,
            body: body
        )
        
        if response.success, let user = response.data, let token = response.token {
            networkConfig.setAuthToken(token)
            return (user, token)
        } else {
            throw APIError.serverError(response.message ?? "Error desconocido")
        }
    }
    
    func register(username: String, email: String, password: String) async throws -> User {
        let body: [String: Any] = [
            "username": username,
            "email": email,
            "password": password,
            "role_id": 2
        ]
        
        let response: RegisterResponse = try await networkConfig.request(
            endpoint: AuthEndpoint.register,
            body: body
        )
        
        if response.success, let user = response.data {
            return user
        } else {
            throw APIError.serverError(response.message ?? "Error desconocido")
        }
    }
}
