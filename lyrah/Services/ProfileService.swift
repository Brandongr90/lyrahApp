//
//  ProfileService.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 24/03/25.
//

import Foundation

class ProfileService {
    private let apiManager: ProfileAPIManager
    
    init(apiManager: ProfileAPIManager = ProfileAPIManager()) {
        self.apiManager = apiManager
    }
    
    func getProfile(forUserId userId: String) async throws -> Profile? {
        do {
            return try await apiManager.getProfile(forUserId: userId)
        } catch let error as APIError {
            if case .serverError(let message) = error, message.contains("no encontrado") {
                // No es realmente un error, solo significa que no hay perfil
                return nil
            }
            throw error
        }
    }
    
    func createProfile(profileData: [String: Any]) async throws {
        try await apiManager.createProfile(profileData: profileData)
    }
}
