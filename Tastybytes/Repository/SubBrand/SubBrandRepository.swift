import Models
import Supabase

protocol SubBrandRepository {
    func insert(newSubBrand: SubBrand.NewRequest) async -> Result<SubBrand, Error>
    func update(updateRequest: SubBrand.Update) async -> Result<Void, Error>
    func delete(id: Int) async -> Result<Void, Error>
    func verification(id: Int, isVerified: Bool) async -> Result<Void, Error>
    func getUnverified() async -> Result<[SubBrand.JoinedBrand], Error>
}

struct SupabaseSubBrandRepository: SubBrandRepository {
    let client: SupabaseClient

    func insert(newSubBrand: SubBrand.NewRequest) async -> Result<SubBrand, Error> {
        do {
            let response: SubBrand = try await client
                .database
                .from(.subBrands)
                .insert(values: newSubBrand, returning: .representation)
                .select(columns: SubBrand.getQuery(.saved(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func update(updateRequest: SubBrand.Update) async -> Result<Void, Error> {
        do {
            let baseQuery = client
                .database
                .from(.subBrands)

            switch updateRequest {
            case let .brand(update):
                try await baseQuery
                    .update(values: update)
                    .eq(column: "id", value: update.id)
                    .execute()
            case let .name(update):
                try await baseQuery
                    .update(values: update)
                    .eq(column: "id", value: update.id)
                    .execute()
            }

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.subBrands)
                .delete()
                .eq(column: "id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func verification(id: Int, isVerified: Bool) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .rpc(fn: .verifySubBrand, params: SubBrand.VerifyRequest(id: id, isVerified: isVerified))
                .single()
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func getUnverified() async -> Result<[SubBrand.JoinedBrand], Error> {
        do {
            let response: [SubBrand.JoinedBrand] = try await client
                .database
                .from(.subBrands)
                .select(columns: SubBrand.getQuery(.joinedBrand(false)))
                .eq(column: "is_verified", value: false)
                .order(column: "created_at", ascending: false)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
