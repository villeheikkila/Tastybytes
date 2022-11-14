import Foundation
import Supabase

protocol SubBrandRepository {
    func insert(newSubBrand: SubBrandNew) async -> Result<SubBrand, Error>
}

struct SupabaseSubBrandRepository: SubBrandRepository {
    let client: SupabaseClient

    func insert(newSubBrand: SubBrandNew) async -> Result<SubBrand, Error> {
        do {
            let response = try await client
                .database
                .from(SubBrand.getQuery(.tableName))
                .insert(values: newSubBrand, returning: .representation)
                .select(columns: SubBrand.getQuery(.saved(false)))
                .single()
                .execute()
                .decoded(to: SubBrand.self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
