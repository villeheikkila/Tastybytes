import Models
import Supabase

struct SupabaseSubBrandRepository: SubBrandRepository {
    let client: SupabaseClient

    func insert(newSubBrand: SubBrand.NewRequest) async -> Result<SubBrand, Error> {
        do {
            let response: SubBrand = try await client
                .from(.subBrands)
                .insert(newSubBrand, returning: .representation)
                .select(SubBrand.getQuery(.saved(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func update(updateRequest: SubBrand.Update) async -> Result<SubBrand, Error> {
        do {
            let baseQuery = client
                .from(.subBrands)

            switch updateRequest {
            case let .brand(update):
                let result: SubBrand = try await baseQuery
                    .update(update)
                    .eq("id", value: update.id)
                    .select(SubBrand.getQuery(.saved(false)))
                    .single()
                    .execute()
                    .value
                return .success(result)
            case let .name(update):
                let result: SubBrand = try await baseQuery
                    .update(update)
                    .eq("id", value: update.id)
                    .select(SubBrand.getQuery(.saved(false)))
                    .single()
                    .execute()
                    .value
                return .success(result)
            }

        } catch {
            return .failure(error)
        }
    }

    func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .from(.subBrands)
                .delete()
                .eq("id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func verification(id: Int, isVerified: Bool) async -> Result<Void, Error> {
        do {
            try await client
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
                .from(.subBrands)
                .select(SubBrand.getQuery(.joinedBrand(false)))
                .eq("is_verified", value: false)
                .order("created_at", ascending: false)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
