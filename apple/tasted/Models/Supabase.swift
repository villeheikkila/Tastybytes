//
//  Supabase.swift
//  tasted
//
//  Created by Ville Heikkilä on 11.10.2022.
//

import Foundation

struct CategoryResponse: Identifiable, Codable, Hashable {
    let id: Int
    let name: String

    static func == (lhs: CategoryResponse, rhs: CategoryResponse) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SubcategoryResponse: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let categories: CategoryResponse

    static func == (lhs: SubcategoryResponse, rhs: SubcategoryResponse) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CompanyResponse: Identifiable, Codable, Hashable {
    let id: Int
    let name: String

    static func == (lhs: CompanyResponse, rhs: CompanyResponse) -> Bool {
        return lhs.id == rhs.id
    }
}

struct BrandResponse: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let companies: CompanyResponse

    static func == (lhs: BrandResponse, rhs: BrandResponse) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SubBrandResponse: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let brands: BrandResponse

    static func == (lhs: SubBrandResponse, rhs: SubBrandResponse) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ProductResponse: Hashable, Identifiable, Codable {
    let id: Int
    let name: String
    let description: String
    let sub_brands: SubBrandResponse
    let subcategories: [SubcategoryResponse]

    static func == (lhs: ProductResponse, rhs: ProductResponse) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ProfileResponse: Identifiable, Codable, Hashable {
    let id: UUID
    let username: String
    let avatar_url: String?

    static func == (lhs: ProfileResponse, rhs: ProfileResponse) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CheckInReactionResponse: Identifiable, Codable, Hashable {
    let id: Int
    let created_by: UUID
    let profiles: ProfileResponse

    static func == (lhs: CheckInReactionResponse, rhs: CheckInReactionResponse) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CheckInResponse: Identifiable, Codable, Hashable {
    let id: Int
    let rating: Double?
    let review: String?
    let created_at: String?
    let profiles: ProfileResponse
    let products: ProductResponse
    let check_in_reactions: [CheckInReactionResponse]

    static func == (lhs: CheckInResponse, rhs: CheckInResponse) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CheckInCommentResponse: Identifiable, Codable, Hashable {
    let id: Int
    let content: String
    let created_at: String
    let profiles: ProfileResponse
    
    
    static func == (lhs: CheckInCommentResponse, rhs: CheckInCommentResponse) -> Bool {
        return lhs.id == rhs.id
    }
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
