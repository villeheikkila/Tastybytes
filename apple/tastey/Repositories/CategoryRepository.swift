import Foundation

struct SupabaseCategoryRepository {
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
}
