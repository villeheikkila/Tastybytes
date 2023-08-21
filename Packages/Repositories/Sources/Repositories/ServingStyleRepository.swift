import Models
import Supabase

public protocol ServingStyleRepository {
    func getAll() async -> Result<[ServingStyle], Error>
    func insert(servingStyle: ServingStyle.NewRequest) async -> Result<ServingStyle, Error>
    func update(update: ServingStyle.UpdateRequest) async -> Result<ServingStyle, Error>
    func delete(id: Int) async -> Result<Void, Error>
}

public struct SupabaseServingStyleRepository: ServingStyleRepository {
    let client: SupabaseClient

    public func getAll() async -> Result<[ServingStyle], Error> {
        do {
            let response: [ServingStyle] = try await client
                .database
                .from(.servingStyles)
                .select(columns: ServingStyle.getQuery(.saved(false)))
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func insert(servingStyle: ServingStyle.NewRequest) async -> Result<ServingStyle, Error> {
        do {
            let response: ServingStyle = try await client
                .database
                .from(.servingStyles)
                .insert(values: servingStyle, returning: .representation)
                .select(columns: ServingStyle.getQuery(.saved(false)))
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
                .from(.servingStyles)
                .delete()
                .eq(column: "id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    public func update(update: ServingStyle.UpdateRequest) async -> Result<ServingStyle, Error> {
        do {
            let response: ServingStyle = try await client
                .database
                .from(.servingStyles)
                .update(
                    values: update,
                    returning: .representation
                )
                .select(columns: ServingStyle.getQuery(.saved(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
