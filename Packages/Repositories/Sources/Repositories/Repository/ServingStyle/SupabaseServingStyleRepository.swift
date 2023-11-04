import Models
import Supabase

struct SupabaseServingStyleRepository: ServingStyleRepository {
    let client: SupabaseClient

    func getAll() async -> Result<[ServingStyle], Error> {
        do {
            let response: [ServingStyle] = try await client
                .database
                .from(.servingStyles)
                .select(ServingStyle.getQuery(.saved(false)))
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func insert(servingStyle: ServingStyle.NewRequest) async -> Result<ServingStyle, Error> {
        do {
            let response: ServingStyle = try await client
                .database
                .from(.servingStyles)
                .insert(servingStyle, returning: .representation)
                .select(ServingStyle.getQuery(.saved(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.servingStyles)
                .delete()
                .eq("id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func update(update: ServingStyle.UpdateRequest) async -> Result<ServingStyle, Error> {
        do {
            let response: ServingStyle = try await client
                .database
                .from(.servingStyles)
                .update(
                    update,
                    returning: .representation
                )
                .select(ServingStyle.getQuery(.saved(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
