//
//  AuthService.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 24/03/25.
//

import Foundation

class AuthService {
    private let apiManager: AuthAPIManager
    private let userDefaultsKey = "loggedInUser"
    private let tokenDefaultsKey = "authToken"
    
    init(apiManager: AuthAPIManager = AuthAPIManager()) {
        self.apiManager = apiManager
    }
    
    func login(email: String? = nil, username: String? = nil, password: String) async throws -> (User, String) {
        do {
            let (user, token) = try await apiManager.login(email: email, username: username, password: password)
            
            // Guardar usuario y token
            saveUserSession(user: user, token: token)
            
            return (user, token)
        } catch {
            throw error
        }
    }
    
    func register(username: String, email: String, password: String) async throws -> User {
        return try await apiManager.register(username: username, email: email, password: password)
    }
    
    func logout() {
        // Limpiamos datos de sesión
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: tokenDefaultsKey)
    }
    
    func loadSavedUserSession() -> (User, String)? {
        guard let token = UserDefaults.standard.string(forKey: tokenDefaultsKey),
              let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
              let user = try? JSONDecoder().decode(User.self, from: userData) else {
                  return nil
              }
        
        print("Sesión cargada exitosamente para el usuario: \(user.username) con ID: \(user.id)")
        return (user, token)
    }
    
    private func saveUserSession(user: User, token: String) {
        // Guardamos el usuario en UserDefaults
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userDefaultsKey)
        }
        
        // Guardamos el token
        UserDefaults.standard.set(token, forKey: tokenDefaultsKey)
        
        // NetworkConfig para las futuras peticiones
        NetworkConfig.default.setAuthToken(token)
    }
}
