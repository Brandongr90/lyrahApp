//
//  APIError.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 24/03/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
    case unknown
}
