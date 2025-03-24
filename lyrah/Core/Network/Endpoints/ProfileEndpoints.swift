//
//  ProfileEndpoints.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 24/03/25.
//

import Foundation

enum ProfileEndpoint: Endpoint {
    case getProfile(userId: String)
    case updateProfile(profileId: String)
    case createProfile
    
    var path: String {
        switch self {
        case .getProfile(let userId):
            return "/profiles/user/\(userId)"
        case .updateProfile(let profileId):
            return "/profiles/\(profileId)"
        case .createProfile:
            return "/profiles"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getProfile:
            return .get
        case .createProfile:
            return .post
        case .updateProfile:
            return .put
        }
    }
}
