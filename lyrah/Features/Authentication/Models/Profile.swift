//
//  Profile.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 11/03/25.
//

import Foundation

struct Profile: Codable, Identifiable {
    let id: String
    let userId: String
    let firstName: String?
    let lastName: String?
    let birthdate: String?
    let gender: String?
    let profilePictureUrl: String?
    let bio: String?
    
    // Información de contacto
    let phone: String?
    let address: String?
    let city: String?
    let state: String?
    let country: String?
    let postalCode: String?
    
    // Las áreas de mejora y actividades serán arrays de opciones
    var improvementAreas: [ImprovementAreaOptionProfile]?
    var wellnessActivities: [WellnessActivityOptionProfile]?
    
    enum CodingKeys: String, CodingKey {
        case id = "profile_id"
        case userId = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case birthdate
        case gender
        case profilePictureUrl = "profile_picture_url"
        case bio
        case phone
        case address
        case city
        case state
        case country
        case postalCode = "postal_code"
        case improvementAreas = "improvement_areas"
        case wellnessActivities = "wellness_activities"
    }
}

struct ImprovementAreaOptionProfile: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "option_id"
        case name
        case description
    }
}

struct WellnessActivityOptionProfile: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "option_id"
        case name
        case description
    }
}
