import Foundation
import Supabase

protocol CategoryRepository {
    func getAllWithSubcategories() async -> Result<[CategoryJoinedWithSubcategories], Error>
    func getServingStylesByCategory(categoryId: Int) async -> Result<CategoryJoinedWithServingStyles, Error>
}

struct SupabaseCategoryRepository: CategoryRepository {
    let client: SupabaseClient

    func getAllWithSubcategories() async -> Result<[CategoryJoinedWithSubcategories], Error> {
        do {
            let response = try await client
                .database
                .from(Category.getQuery(.tableName))
                .select(columns: Category.getQuery(.joinedSubcategories(false)))
                .order(column: "name")
                .execute()
                .decoded(to: [CategoryJoinedWithSubcategories].self)
            
            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getServingStylesByCategory(categoryId: Int) async -> Result<CategoryJoinedWithServingStyles, Error> {
        do {
            let response = try await client
                .database
                .from(Category.getQuery(.tableName))
                .select(columns: Category.getQuery(.joinedServingStyles(false)))
                .eq(column: "id", value: categoryId)
                .limit(count: 1)
                .single()
                .execute()
                .decoded(to: CategoryJoinedWithServingStyles.self)
            
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
