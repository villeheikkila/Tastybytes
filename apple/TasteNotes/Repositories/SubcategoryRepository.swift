import Foundation
import Supabase

protocol SubcategoryRepository {
    func insert(newSubcategory: Subcategory.NewRequest) async -> Result<Subcategory, Error>
}

struct SupabaseSubcategoryRepository: SubcategoryRepository {
    let client: SupabaseClient

    func insert(newSubcategory: Subcategory.NewRequest) async -> Result<Subcategory, Error> {
        do {
            let response = try await client
                .database
                .from(Subcategory.getQuery(.tableName))
                .insert(values: newSubcategory, returning: .representation)
                .select(columns: Subcategory.getQuery(.saved(false)))
                .single()
                .execute()
                .decoded(to: Subcategory.self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
