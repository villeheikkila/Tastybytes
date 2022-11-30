import Foundation
import Supabase

protocol SubBrandRepository {
    func insert(newSubBrand: SubBrand.NewRequest) async -> Result<SubBrand, Error>
    func update(updateRequest: SubBrand.UpdateRequest) async -> Result<Void, Error>
}

struct SupabaseSubBrandRepository: SubBrandRepository {
    let client: SupabaseClient

    func insert(newSubBrand: SubBrand.NewRequest) async -> Result<SubBrand, Error> {
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
    
    func update(updateRequest: SubBrand.UpdateRequest) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(SubBrand.getQuery(.tableName))
                .update(values: updateRequest)
                .eq(column: "id", value: updateRequest.id)
                .execute()
            
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
