import Models
import Supabase

public protocol SubcategoryRepository {
    func insert(newSubcategory: Subcategory.NewRequest) async -> Result<Subcategory, Error>
    func delete(id: Int) async -> Result<Void, Error>
    func update(updateRequest: Subcategory.UpdateRequest) async -> Result<Void, Error>
    func verification(id: Int, isVerified: Bool) async -> Result<Void, Error>
}

public struct SupabaseSubcategoryRepository: SubcategoryRepository {
    let client: SupabaseClient

    public func insert(newSubcategory: Subcategory.NewRequest) async -> Result<Subcategory, Error> {
        do {
            let response: Subcategory = try await client
                .database
                .from(.subcategories)
                .insert(values: newSubcategory, returning: .representation)
                .select(columns: Subcategory.getQuery(.saved(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.subcategories)
                .delete()
                .eq(column: "id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    public func update(updateRequest: Subcategory.UpdateRequest) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.subcategories)
                .update(values: updateRequest)
                .eq(column: "id", value: updateRequest.id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    public func verification(id: Int, isVerified: Bool) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .rpc(fn: .verifySubcategory, params: Subcategory.VerifyRequest(id: id, isVerified: isVerified))
                .single()
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
