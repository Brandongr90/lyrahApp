//
//  APIService.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 11/03/25.
//

import Foundation

class APIService {
    // Cambiar a la URL de tu API cuando esté lista
    private let baseURL = "http://localhost:3000/api"
    
    // Singleton para acceso global
    static let shared = APIService()
    
    private init() {}
    
    // Token de autenticación
    private var authToken: String?
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    func clearAuthToken() {
        self.authToken = nil
    }
    
    // MARK: - Auth Methods
    
    func login(email: String? = nil, username: String? = nil, password: String, completion: @escaping (Result<(User, String), APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/login") else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Construimos los datos para enviar
        var loginData: [String: Any] = [
            "password": password
        ]
        
        if let email = email, !email.isEmpty {
            loginData["email"] = email
        } else if let username = username, !username.isEmpty {
            loginData["username"] = username
        } else {
            completion(.failure(.serverError("Se requiere email o username")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginData)
        } catch {
            completion(.failure(.networkError(error)))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.unknown))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(LoginResponse.self, from: data)
                
                if response.success, let loginData = response.data {
                    let user = loginData.user.toUser() // Convierte LoginUser a User
                    let token = loginData.token
                    // Guardamos el token para futuras peticiones
                    self.authToken = token
                    completion(.success((user, token)))
                } else {
                    completion(.failure(.serverError(response.message ?? "Error desconocido")))
                }
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    func register(username: String, email: String, password: String, completion: @escaping (Result<User, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let registerData: [String: Any] = [
            "username": username,
            "email": email,
            "password": password,
            "role_id": 2  // Rol de usuario regular
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: registerData)
        } catch {
            completion(.failure(.networkError(error)))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.unknown))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(RegisterResponse.self, from: data)
                
                if response.success, let user = response.data {
                    completion(.success(user))
                } else {
                    completion(.failure(.serverError(response.message ?? "Error desconocido")))
                }
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - Profile Methods
    
    func getProfile(forUserId userId: String, completion: @escaping (Result<Profile?, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/profiles/user/\(userId)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.unknown))
                return
            }
            
            // Estructura para parsear la respuesta
            struct ProfileResponse: Codable {
                let success: Bool
                let data: Profile?
                let message: String?
                let error: String?
            }
            
            do {
                let response = try JSONDecoder().decode(ProfileResponse.self, from: data)
                
                if response.success {
                    completion(.success(response.data))
                } else {
                    // Si el perfil no existe, devolvemos nil pero sin error
                    if response.message?.contains("no encontrado") ?? false {
                        completion(.success(nil))
                    } else {
                        completion(.failure(.serverError(response.message ?? "Error desconocido")))
                    }
                }
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
}
