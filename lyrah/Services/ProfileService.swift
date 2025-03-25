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
        return try await apiManager.getProfile(forUserId: userId)
    }
    
    func createProfile(profileData: [String: Any]) async throws {
        try await apiManager.createProfile(profileData: profileData)
    }
}
