import Foundation

protocol SubBrandRepository {
    func insert(newSubBrand: SubBrandNew) async throws -> SubBrand
}

struct SupabaseSubBrandRepository: SubBrandRepository {
    private let database = Supabase.client.database
    private let tableName = "sub_brands"
    private let saved = "id, name"
    
    func insert(newSubBrand: SubBrandNew) async throws -> SubBrand {
        return try await database
            .from(tableName)
            .insert(values: newSubBrand, returning: .representation)
            .select(columns: saved)
            .single()
            .execute()
            .decoded(to: SubBrand.self)
    }
}
