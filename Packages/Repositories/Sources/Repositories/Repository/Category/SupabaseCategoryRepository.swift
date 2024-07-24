import Models
internal import Supabase

struct SupabaseCategoryRepository: CategoryRepository {
    let client: SupabaseClient

    func getAllWithSubcategoriesServingStyles() async throws -> [Models.Category.JoinedSubcategoriesServingStyles] {
        try await client
            .from(.categories)
            .select(Models.Category.getQuery(.joinedSubcategoriesServingStyles(false)))
            .order("name")
            .execute()
            .value
    }

    func getDetailed(id: Category.Id) async throws -> Category.Detailed {
        try await client
            .from(.categories)
            .select(Models.Category.getQuery(.detailed(false)))
            .eq("id", value: id.rawValue)
            .order("name")
            .limit(1)
            .single()
            .execute()
            .value
    }

    func insert(name: String) async throws -> Models.Category.JoinedSubcategoriesServingStyles {
        try await client
            .from(.categories)
            .insert(["name": name], returning: .representation)
            .select(Models.Category.getQuery(.joinedSubcategoriesServingStyles(false)))
            .single()
            .execute()
            .value
    }

    func addServingStyle(categoryId: Category.Id, servingStyleId: ServingStyle.Id) async throws {
        try await client
            .from(.servingStyles)
            .insert(["category_id": categoryId.rawValue, "serving_style_id": servingStyleId.rawValue])
            .execute()
    }

    func deleteCategory(id: Category.Id) async throws {
        try await client
            .from(.categories)
            .delete()
            .eq("id", value: id.rawValue)
            .execute()
    }

    func deleteServingStyle(categoryId: Category.Id, servingStyleId: ServingStyle.Id) async throws {
        try await client
            .from(.servingStyles)
            .delete()
            .eq("category_id", value: categoryId.rawValue)
            .eq("serving_style_id", value: servingStyleId.rawValue)
            .execute()
    }
}
