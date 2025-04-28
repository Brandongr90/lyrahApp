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
    
    struct RegisterResponse: Decodable {
        let success: Bool
        let message: String?
        let data: RegisterData?
        let error: String?
    }
    
    struct RegisterData: Decodable {
        let user: User
        let token: String
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
        
        // Para debug, imprime la URL y el body
        if let jsonData = try? JSONSerialization.data(withJSONObject: body),
           let _ = String(data: jsonData, encoding: .utf8) {
        }
        
        do {
            let response: LoginResponse = try await networkConfig.request(
                endpoint: AuthEndpoint.login,
                body: body
            )
            
            if response.success, let loginData = response.data {
                networkConfig.setAuthToken(loginData.token)
                return (loginData.user.toUser(), loginData.token)
            } else {
                throw APIError.serverError(response.message ?? "Error desconocido")
            }
        } catch {
            throw error
        }
    }
    
    func register(username: String, email: String, password: String) async throws -> User {
        let body: [String: Any] = [
            "username": username,
            "email": email,
            "password": password,
            "role_id": 2
        ]
        
        // Obtener respuesta cruda
        let url = URL(string: "\(networkConfig.baseURL)\(AuthEndpoint.register.path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        // Intentar decodificar
        do {
            let response = try JSONDecoder().decode(RegisterResponse.self, from: data)
            
            if response.success, let registerData = response.data {
                // Agregar hasProfile manualmente y retornar el usuario
                var userWithProfile = registerData.user
                userWithProfile.hasProfile = false
                
                // Importante: también deberíamos guardar el token aquí
                networkConfig.setAuthToken(registerData.token)
                
                return userWithProfile
            } else {
                throw APIError.serverError(response.message ?? "Error desconocido")
            }
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
