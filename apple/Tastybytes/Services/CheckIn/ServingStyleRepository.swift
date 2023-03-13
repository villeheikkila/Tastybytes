import Supabase

protocol ServingStyleRepository {
  func getAll() async -> Result<[ServingStyle], Error>
  func insert(servingStyle: ServingStyle.NewRequest) async -> Result<ServingStyle, Error>
  func update(update: ServingStyle.UpdateRequest) async -> Result<ServingStyle, Error>
  func delete(id: Int) async -> Result<Void, Error>
}

struct SupabaseServingStyleRepository: ServingStyleRepository {
  let client: SupabaseClient

  func getAll() async -> Result<[ServingStyle], Error> {
    do {
      let response: [ServingStyle] = try await client
        .database
        .from(ServingStyle.getQuery(.tableName))
        .select(columns: ServingStyle.getQuery(.saved(false)))
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
        .from(ServingStyle.getQuery(.tableName))
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

  func delete(id: Int) async -> Result<Void, Error> {
    do {
      try await client
        .database
        .from(ServingStyle.getQuery(.tableName))
        .delete()
        .eq(column: "id", value: id)
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
        .from(ServingStyle.getQuery(.tableName))
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
