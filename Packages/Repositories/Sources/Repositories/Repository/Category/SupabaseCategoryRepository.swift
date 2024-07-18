import Models
internal import Supabase

struct SupabaseCategoryRepository: CategoryRepository {
    let client: SupabaseClient

    func getAllWithSubcategoriesServingStyles() async throws -> [Models.Category.JoinedSubcategoriesServingStyles] {
        try await client
            .from(.categories)
            .select(Models.Category.getQuery(.joinedSubcaategoriesServingStyles(false)))
            .order("name")
            .execute()
            .value
    }

    func getDetailed(id: Int) async throws -> Category.Detailed {
        try await client
            .from(.categories)
            .select(Models.Category.getQuery(.detailed(false)))
            .eq("id", value: id)
            .order("name")
            .limit(1)
            .single()
            .execute()
            .value
    }

    func insert(newCategory: Category.NewRequest) async throws -> Models.Category.JoinedSubcategoriesServingStyles {
        try await client
            .from(.categories)
            .insert(newCategory, returning: .representation)
            .select(Models.Category.getQuery(.joinedSubcaategoriesServingStyles(false)))
            .single()
            .execute()
            .value
    }

    func addServingStyle(categoryId: Int, servingStyleId: Int) async throws {
        try await client
            .from(.servingStyles)
            .insert(Category.NewServingStyleRequest(categoryId: categoryId, servingStyleId: servingStyleId))
            .execute()
    }

    func deleteCategory(id: Int) async throws {
        try await client
            .from(.categories)
            .delete()
            .eq("id", value: id)
            .execute()
    }

    func deleteServingStyle(categoryId: Int, servingStyleId: Int) async throws {
        try await client
            .from(.servingStyles)
            .delete()
            .eq("category_id", value: categoryId)
            .eq("serving_style_id", value: servingStyleId)
            .execute()
    }
}
