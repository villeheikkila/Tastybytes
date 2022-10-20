import Foundation
import Supabase

protocol CategoryRepository {
    func getAllWithSubcategories() async throws -> [CategoryJoinedWithSubcategories]
    func getServingStylesByCategory(categoryId: Int) async throws -> CategoryJoinedWithServingStyles
}

struct SupabaseCategoryRepository: CategoryRepository {
    let client: SupabaseClient
    private let categories = "categories"
    private let joinedWithSubcategories = "id, name, subcategories (id, name)"
    
    
    func getAllWithSubcategories() async throws -> [CategoryJoinedWithSubcategories] {
        return try await client
            .database
            .from(categories)
            .select(columns: joinedWithSubcategories)
            .order(column: "name")
            .execute()
            .decoded(to: [CategoryJoinedWithSubcategories].self)
    }
    
    func getServingStylesByCategory(categoryId: Int) async throws -> CategoryJoinedWithServingStyles {
        return try await client
            .database
            .from("categories")
            .select(columns: "id, name, serving_styles (id, name)")
            .eq(column: "id", value: categoryId)
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: CategoryJoinedWithServingStyles.self)
    }
}
