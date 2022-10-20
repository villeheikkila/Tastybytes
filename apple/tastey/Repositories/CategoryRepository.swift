import Foundation

protocol CategoryRepository {
    func loadAllWithSubcategories() async throws -> [CategoryJoinedWithSubcategories]
    func loadServingStyles(categoryId: Int) async throws -> CategoryJoinedWithServingStyles
}

struct SupabaseCategoryRepository: CategoryRepository {
    private let database = Supabase.client.database
    private let categories = "categories"
    private let joinedWithSubcategories = "id, name, subcategories (id, name)"
    
    
    func loadAllWithSubcategories() async throws -> [CategoryJoinedWithSubcategories] {
        return try await database
            .from(categories)
            .select(columns: joinedWithSubcategories)
            .order(column: "name")
            .execute()
            .decoded(to: [CategoryJoinedWithSubcategories].self)
    }
    
    func loadServingStyles(categoryId: Int) async throws -> CategoryJoinedWithServingStyles {
        return try await database
            .from("categories")
            .select(columns: "id, name, serving_styles (id, name)")
            .eq(column: "id", value: categoryId)
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: CategoryJoinedWithServingStyles.self)
    }
}
