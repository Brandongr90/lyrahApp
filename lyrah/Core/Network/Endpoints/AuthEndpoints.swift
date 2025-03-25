//
//  AuthEndpoints.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 24/03/25.
//

import Foundation

enum AuthEndpoint: Endpoint {
    case login
    case register
    case refreshToken
    
    var path: String {
        switch self {
        case .login: return "/users/login"
        case .register: return "/users/register"
        case .refreshToken: return "/auth/refresh-token"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .register, .refreshToken: return .post
        }
    }
}
