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
    var check_in_reactions: [CheckInReactionResponse]
}
