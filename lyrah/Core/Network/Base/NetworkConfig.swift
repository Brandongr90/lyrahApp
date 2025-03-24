//
//  NetworkConfig.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 24/03/25.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
}

class NetworkConfig {
    static let `default` = NetworkConfig(baseURL: "http://localhost:3000/api")
    
    let baseURL: String
    private var authToken: String?
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    func clearAuthToken() {
        self.authToken = nil
    }
    
    func request<T: Decodable>(endpoint: any Endpoint, body: [String: Any]? = nil) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint.path)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                throw APIError.networkError(error)
            }
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
}
