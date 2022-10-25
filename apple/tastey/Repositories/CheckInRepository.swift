import Foundation
import Supabase

protocol CheckInRepository {
    func getActivityFeed(from: Int, to: Int) async throws -> [CheckIn]
    func getByProfileId(id: UUID, from: Int, to: Int) async throws -> [CheckIn]
    func getByProductId(id: Int, from: Int, to: Int) async throws -> [CheckIn]
    func create(newCheckInParams: NewCheckInParams) async throws -> CheckIn
    func update(updateCheckInParams: UpdateCheckInParams) async throws -> CheckIn
    func delete(id: Int) async throws -> Void
    func getSummaryByProfileId(id: UUID) async throws -> ProfileSummary
}

struct SupabaseCheckInRepository: CheckInRepository {
    let client: SupabaseClient
    private let tableName = "check_ins"
    private let checkInJoined = "id, rating, review, image_url, created_at, serving_styles (id, name), profiles (id, username, first_name, last_name, avatar_url, name_display), products (id, name, description, sub_brands (id, name, brands (id, name, companies (id, name, logo_url))), subcategories (id, name, categories (id, name))), check_in_reactions (id, created_by, profiles (id, username, first_name, last_name, avatar_url, name_display)), check_in_flavors (flavors (id, name)), check_in_tagged_profiles (profiles (id, username, first_name, last_name, avatar_url, name_display)), product_variants (id, companies (id, name, logo_url))"
    
    func getActivityFeed(from: Int, to: Int) async throws -> [CheckIn] {
        return try await client
            .database
            .rpc(fn: "fnc__get_activity_feed")
            .select(columns: checkInJoined)
            .range(from: from, to: to)
            .execute()
            .decoded(to: [CheckIn].self)
    }
    
    func getByProfileId(id: UUID, from: Int, to: Int) async throws -> [CheckIn] {
        return try await client
            .database
            .from(tableName)
            .select(columns: checkInJoined)
            .eq(column: "created_by", value: id.uuidString.lowercased())
            .order(column: "id", ascending: false)
            .range(from: from, to: to)
            .execute()
            .decoded(to: [CheckIn].self)
    }
    
    func getByProductId(id: Int, from: Int, to: Int) async throws -> [CheckIn] {
        return try await client
            .database
            .from(tableName)
            .select(columns: checkInJoined)
            .eq(column: "product_id", value: id)
            .order(column: "created_at", ascending: false)
            .range(from: from, to: to)
            .execute()
            .decoded(to: [CheckIn].self)
    }
    
    func create(newCheckInParams: NewCheckInParams) async throws -> CheckIn {
        return try await client
            .database
            .rpc(fn: "fnc__create_check_in", params: newCheckInParams)
            .select(columns: checkInJoined)
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: CheckIn.self)
    }
    
    func update(updateCheckInParams: UpdateCheckInParams) async throws -> CheckIn {
        return try await client
            .database
            .rpc(fn: "fnc__update_check_in", params: updateCheckInParams)
            .select(columns: checkInJoined)
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: CheckIn.self)
    }
    
    
    func delete(id: Int) async throws -> Void {
        try await client
            .database
            .from(tableName)
            .delete()
            .eq(column: "id", value: id)
            .execute()
    }
    
    func getSummaryByProfileId(id: UUID) async throws -> ProfileSummary {
        return try await client
            .database
            .rpc(fn: "fnc__get_profile_summary", params: GetProfileSummaryParams(profileId: id))
            .select()
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: ProfileSummary.self)
    }
}

