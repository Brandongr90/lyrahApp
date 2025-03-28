//
//  ProfileAPIManager.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 24/03/25.
//

import Foundation

class ProfileAPIManager {
    private let networkConfig: NetworkConfig
    
    init(networkConfig: NetworkConfig = .default) {
        self.networkConfig = networkConfig
    }
    
    struct ProfileResponse: Decodable {
        let success: Bool
        let data: Profile?
        let message: String?
        let error: String?
    }
    
    struct CreateProfileResponse: Decodable {
        let success: Bool
        let message: String?
        let data: Profile?
        let error: String?
    }
    
    func getProfile(forUserId userId: String) async throws -> Profile? {
        let response: ProfileResponse = try await networkConfig.request(
            endpoint: ProfileEndpoint.getProfile(userId: userId)
        )
        
        if response.success {
            return response.data
        } else {
            // Si el perfil no existe, devolvemos nil pero sin error
            if response.message?.contains("no encontrado") ?? false {
                return nil
            } else {
                throw APIError.serverError(response.message ?? "Error desconocido")
            }
        }
    }
    
    func createProfile(profileData: [String: Any]) async throws {
        let response: CreateProfileResponse = try await networkConfig.request(
            endpoint: ProfileEndpoint.createProfile,
            body: profileData
        )
        
        if !response.success {
            throw APIError.serverError(response.message ?? "Error al crear el perfil")
        }
    }
}
