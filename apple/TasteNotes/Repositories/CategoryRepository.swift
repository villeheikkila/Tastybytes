import Foundation
import Supabase

protocol CategoryRepository {
    func getAllWithSubcategories() async throws -> [CategoryJoinedWithSubcategories]
    func getServingStylesByCategory(categoryId: Int) async throws -> CategoryJoinedWithServingStyles
}

struct SupabaseCategoryRepository: CategoryRepository {
    let client: SupabaseClient
    
    func getAllWithSubcategories() async throws -> [CategoryJoinedWithSubcategories] {
        return try await client
            .database
            .from(Category.getQuery(.tableName))
            .select(columns: Category.getQuery(.joinedSubcategories(false)))
            .order(column: "name")
            .execute()
            .decoded(to: [CategoryJoinedWithSubcategories].self)
    }
    
    func getServingStylesByCategory(categoryId: Int) async throws -> CategoryJoinedWithServingStyles {
        return try await client
            .database
            .from(Category.getQuery(.tableName))
            .select(columns: Category.getQuery(.joinedServingStyles(false)))
            .eq(column: "id", value: categoryId)
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: CategoryJoinedWithServingStyles.self)
    }
}
