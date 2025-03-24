//
//  AppConstants.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 24/03/25.
//

import Foundation

struct AppConstants {
    struct API {
        static let baseURL = "http://localhost:3000/api"
    }
    
    struct Storage {
        static let userKey = "loggedInUser"
        static let tokenKey = "authToken"
    }
}
