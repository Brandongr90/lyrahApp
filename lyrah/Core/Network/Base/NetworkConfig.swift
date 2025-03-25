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
    
    var hasToken: Bool {
        return authToken != nil
    }
    
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
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Imprimir respuesta para debug
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Respuesta del servidor: \(jsonString)")
            }
            
            // Verificar si hay respuesta HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Verificar el código de estado HTTP
            if httpResponse.statusCode >= 400 {
                throw APIError.serverError("Error de servidor: \(httpResponse.statusCode)")
            }
            
            // Intentar decodificar
            return try JSONDecoder().decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            print("Error de decodificación en request: \(decodingError)")
            throw APIError.decodingError(decodingError)
        } catch {
            throw APIError.networkError(error)
        }
    }
}
