//
//  AuthViewModel.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 11/03/25.
//

import SwiftUI
import AuthenticationServices
import Combine
// import GoogleSignIn

enum AuthState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated(User)  // Usuario autenticado, puede tener o no perfil
    case error(String)        // Error ocurrido durante la autenticación
    
    // Implementación manual de `Equatable`
    static func == (lhs: AuthState, rhs: AuthState) -> Bool {
        switch (lhs, rhs) {
        case (.unauthenticated, .unauthenticated):
            return true
        case (.authenticating, .authenticating):
            return true
        case (.authenticated(let lhsUser), .authenticated(let rhsUser)):
            return lhsUser == rhsUser
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

enum OnboardingState {
    case notStarted     // El usuario es nuevo y debe crear su perfil
    case completed      // El usuario ya tiene perfil
}

class AuthViewModel: ObservableObject {
    @Published var authState: AuthState = .unauthenticated
    @Published var onboardingState: OnboardingState = .notStarted
    @Published var loginCredentials = LoginCredentials()
    @Published var isShowingRegister = false
    @Published var registerCredentials = LoginCredentials()
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    private let authService = AuthService()
    private let profileService = ProfileService()
    
    init() {
        // Intentar restaurar la sesión al iniciar
        loadSavedUserSession()
    }
    
    // Actualizamos los métodos para usar async/await con Task
    
    func login() {
        guard validateLoginCredentials() else { return }
        
        authState = .authenticating
        
        Task {
            do {
                let (user, _) = try await authService.login(
                    email: loginCredentials.email.isEmpty ? nil : loginCredentials.email,
                    username: loginCredentials.username.isEmpty ? nil : loginCredentials.username,
                    password: loginCredentials.password
                )
                
                DispatchQueue.main.async {
                    self.authState = .authenticated(user)
                    self.checkIfUserHasProfile(userId: user.id)
                }
            } catch let error as APIError {
                DispatchQueue.main.async {
                    self.handleAuthError(error)
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleAuthError(.unknown)
                }
            }
        }
    }
    
    func register() {
        guard validateRegisterCredentials() else { return }
        
        authState = .authenticating
        
        Task {
            do {
                let _ = try await authService.register(
                    username: registerCredentials.username,
                    email: registerCredentials.email,
                    password: registerCredentials.password
                )
                
                DispatchQueue.main.async {
                    // Después de registrarse, intentamos iniciar sesión automáticamente
                    self.loginAfterRegistration()
                }
            } catch let error as APIError {
                DispatchQueue.main.async {
                    self.handleAuthError(error)
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleAuthError(.unknown)
                }
            }
        }
    }
    
    func logout() {
        authService.logout()
        
        // Reseteamos el estado
        authState = .unauthenticated
        onboardingState = .notStarted
        loginCredentials = LoginCredentials()
    }
    
    func checkIfUserHasProfile(userId: String) {
        Task {
            do {
                let profile = try await profileService.getProfile(forUserId: userId)
                
                DispatchQueue.main.async {
                    // Si el perfil existe, marcamos onboarding como completado
                    self.onboardingState = profile != nil ? .completed : .notStarted
                }
            } catch {
                DispatchQueue.main.async {
                    // Si hay un error, asumimos que no hay perfil
                    self.onboardingState = .notStarted
                }
            }
        }
    }
    
    // El resto de los métodos (helpers, validación, etc.) se mantienen igual
    private func loginAfterRegistration() {
        // Transferimos las credenciales de registro a login
        loginCredentials = registerCredentials
        // Limpiamos credenciales de registro
        registerCredentials = LoginCredentials()
        // Iniciamos sesión con las credenciales del registro
        login()
    }
    
    private func validateLoginCredentials() -> Bool {
        // Al menos debe haber un email o username
        if loginCredentials.email.isEmpty && loginCredentials.username.isEmpty {
            self.showAlert = true
            self.alertMessage = "Por favor ingresa tu email o nombre de usuario"
            return false
        }
        
        // Debe tener una contraseña
        if loginCredentials.password.isEmpty {
            self.showAlert = true
            self.alertMessage = "Por favor ingresa tu contraseña"
            return false
        }
        
        return true
    }
    
    private func validateRegisterCredentials() -> Bool {
        // Validar username
        if registerCredentials.username.isEmpty {
            self.showAlert = true
            self.alertMessage = "Por favor ingresa un nombre de usuario"
            return false
        }
        
        // Validar email
        if registerCredentials.email.isEmpty || !isValidEmail(registerCredentials.email) {
            self.showAlert = true
            self.alertMessage = "Por favor ingresa un email válido"
            return false
        }
        
        // Validar contraseña - mínimo 6 caracteres
        if registerCredentials.password.count < 6 {
            self.showAlert = true
            self.alertMessage = "La contraseña debe tener al menos 6 caracteres"
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func handleAuthError(_ error: APIError) {
        switch error {
        case .serverError(let message):
            self.alertMessage = message
        case .networkError:
            self.alertMessage = "Error de red. Por favor verifica tu conexión a internet."
        case .decodingError:
            self.alertMessage = "Error al procesar la respuesta del servidor."
        default:
            self.alertMessage = "Ha ocurrido un error inesperado."
        }
        
        self.showAlert = true
        self.authState = .error(self.alertMessage)
    }
    
    private func loadSavedUserSession() {
        if let (user, token) = authService.loadSavedUserSession() {
            // Restauramos el estado de autenticación
            self.authState = .authenticated(user)
            
            // Verificamos si el usuario tiene perfil
            self.checkIfUserHasProfile(userId: user.id)
        }
    }
}
