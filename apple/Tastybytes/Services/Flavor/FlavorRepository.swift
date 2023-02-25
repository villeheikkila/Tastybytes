import Foundation
import PostgREST
import Supabase

protocol FlavorRepository {
  func getAll() async -> Result<[Flavor], Error>
  func insert(newFlavor: Flavor.NewRequest) async -> Result<Flavor, Error>
  func delete(id: Int) async -> Result<Void, Error>
}

struct SupabaseFlavorRepository: FlavorRepository {
  let client: SupabaseClient

  func getAll() async -> Result<[Flavor], Error> {
    do {
      let response: [Flavor] = try await client
        .database
        .from(Flavor.getQuery(.tableName))
        .select(columns: Flavor.getQuery(.saved(false)))
        .order(column: "name")
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
        .database
        .from(Flavor.getQuery(.tableName))
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

  func delete(id: Int) async -> Result<Void, Error> {
    do {
      try await client
        .database
        .from(Flavor.getQuery(.tableName))
        .delete()
        .eq(column: "id", value: id)
        .execute()

      return .success(())
    } catch {
      return .failure(error)
    }
  }
}
