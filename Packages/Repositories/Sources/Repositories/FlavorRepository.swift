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

public extension Flavor {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.flavors.rawValue
        let saved = "id, name"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
    }
}
