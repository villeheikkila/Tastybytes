//
//  Supabase.swift
//  tasted
//
//  Created by Ville Heikkilä on 11.10.2022.
//

import Foundation

struct CategoryResponse: Identifiable, Codable {
    let id: Int
    let name: String
}

struct SubcategoryResponse: Identifiable, Codable {
    let id: Int
    let name: String
    let categories: CategoryResponse
}

struct CompanyResponse: Identifiable, Codable {
    let id: Int
    let name: String
}

struct BrandResponse: Identifiable, Codable {
    let id: Int
    let name: String
    let companies: CompanyResponse
}

struct SubBrandResponse: Identifiable, Codable {
    let id: Int
    let name: String
    let brands: BrandResponse
}

struct ProductResponse: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String
    let sub_brands: SubBrandResponse
    let subcategories: [SubcategoryResponse]
}

struct ProfileResponse: Identifiable, Codable {
    let id: UUID
    let username: String
    let avatar_url: String?
}

struct CheckInReactionResponse: Identifiable, Codable {
    let id: Int
    let created_by: UUID
    let profiles: ProfileResponse
}

struct CheckInResponse: Identifiable, Codable {
    let id: Int
    let rating: Double?
    let review: String?
    let created_at: String?
    let profiles: ProfileResponse
    let products: ProductResponse
    let check_in_reactions: [CheckInReactionResponse]
}

struct ProfileSummary: Codable {
    let total_check_ins: Int
    let unique_check_ins: Int
    let average_rating: Double?
    let unrated: Int
    let rating_0: Int
    let rating_1: Int
    let rating_2: Int
    let rating_3: Int
    let rating_4: Int
    let rating_5: Int
    let rating_6: Int
    let rating_7: Int
    let rating_8: Int
    let rating_9: Int
    let rating_10: Int
}
