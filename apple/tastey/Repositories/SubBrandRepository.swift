import Foundation
import Supabase

protocol SubBrandRepository {
    func insert(newSubBrand: SubBrandNew) async throws -> SubBrand
}

struct SupabaseSubBrandRepository: SubBrandRepository {
    let client: SupabaseClient
    private let tableName = "sub_brands"
    private let saved = "id, name"
    
    func insert(newSubBrand: SubBrandNew) async throws -> SubBrand {
        return try await client
            .database
            .from(tableName)
            .insert(values: newSubBrand, returning: .representation)
            .select(columns: saved)
            .single()
            .execute()
            .decoded(to: SubBrand.self)
    }
}
