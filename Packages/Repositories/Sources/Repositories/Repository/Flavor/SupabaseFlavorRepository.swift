import Models
internal import Supabase

struct SupabaseFlavorRepository: FlavorRepository {
    let client: SupabaseClient

    func getAll() async -> Result<[Flavor], Error> {
        do {
            let response: [Flavor] = try await client
                .from(.flavors)
                .select(Flavor.getQuery(.saved(false)))
                .order("name")
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func insert(newFlavor: Flavor.NewRequest) async -> Result<Flavor, Error> {
        do {
            let response: Flavor = try await client
                .from(.flavors)
                .insert(newFlavor, returning: .representation)
                .select(Flavor.getQuery(.saved(false)))
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
                .from(.flavors)
                .delete()
                .eq("id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
