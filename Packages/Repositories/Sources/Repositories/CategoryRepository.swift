import Models
import Supabase

public protocol CategoryRepository {
    func getAllWithSubcategoriesServingStyles() async
        -> Result<[Models.Category.JoinedSubcategoriesServingStyles], Error>
    func insert(newCategory: Category.NewRequest) async -> Result<Void, Error>
    func addServingStyle(categoryId: Int, servingStyleId: Int) async -> Result<Void, Error>
    func deleteServingStyle(categoryId: Int, servingStyleId: Int) async -> Result<Void, Error>
}

public struct SupabaseCategoryRepository: CategoryRepository {
    let client: SupabaseClient

    public func getAllWithSubcategoriesServingStyles() async
    -> Result<[Models.Category.JoinedSubcategoriesServingStyles], Error> {
        do {
            let response: [Models.Category.JoinedSubcategoriesServingStyles] = try await client
                .database
                .from(.categories)
                .select(columns: Category.getQuery(.joinedSubcaategoriesServingStyles(false)))
                .order(column: "name")
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func insert(newCategory: Category.NewRequest) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.categories)
                .insert(values: newCategory, returning: .representation)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    public func addServingStyle(categoryId: Int, servingStyleId: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.servingStyles)
                .insert(values: Category.NewServingStyleRequest(categoryId: categoryId, servingStyleId: servingStyleId))
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    public func deleteServingStyle(categoryId: Int, servingStyleId: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.servingStyles)
                .delete()
                .eq(column: "category_id", value: categoryId)
                .eq(column: "serving_style_id", value: servingStyleId)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}

public extension Category {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.categories.rawValue
        let servingStyleTableName = Database.Table.categoryServingStyles.rawValue
        let saved = "id, name, icon"

        switch queryType {
        case .tableName:
            return tableName
        case .servingStyleTableName:
            return servingStyleTableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joinedSubcaategoriesServingStyles(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Subcategory.getQuery(.saved(true)), ServingStyle.getQuery(.saved(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case servingStyleTableName
        case saved(_ withTableName: Bool)
        case joinedSubcaategoriesServingStyles(_ withTableName: Bool)
    }
}
