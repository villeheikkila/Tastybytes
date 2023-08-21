import Models
import Supabase

public protocol FlavorRepository {
    func getAll() async -> Result<[Flavor], Error>
    func insert(newFlavor: Flavor.NewRequest) async -> Result<Flavor, Error>
    func delete(id: Int) async -> Result<Void, Error>
}

public struct SupabaseFlavorRepository: FlavorRepository {
    let client: SupabaseClient

    public func getAll() async -> Result<[Flavor], Error> {
        do {
            let response: [Flavor] = try await client
                .database
                .from(.flavors)
                .select(columns: Flavor.getQuery(.saved(false)))
                .order(column: "name")
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func insert(newFlavor: Flavor.NewRequest) async -> Result<Flavor, Error> {
        do {
            let response: Flavor = try await client
                .database
                .from(.flavors)
                .insert(values: newFlavor, returning: .representation)
                .select(columns: Flavor.getQuery(.saved(false)))
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
                .from(.flavors)
                .delete()
                .eq(column: "id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
