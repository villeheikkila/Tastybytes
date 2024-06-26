import Models
import Supabase

struct SupabaseCategoryRepository: CategoryRepository {
    let client: SupabaseClient

    func getAllWithSubcategoriesServingStyles() async
        -> Result<[Models.Category.JoinedSubcategoriesServingStyles], Error>
    {
        do {
            let response: [Models.Category.JoinedSubcategoriesServingStyles] = try await client
                .from(.categories)
                .select(Models.Category.getQuery(.joinedSubcaategoriesServingStyles(false)))
                .order("name")
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func insert(newCategory: Category.NewRequest) async -> Result<Models.Category.JoinedSubcategoriesServingStyles, Error> {
        do {
            let result: Models.Category.JoinedSubcategoriesServingStyles = try await client
                .from(.categories)
                .insert(newCategory, returning: .representation)
                .select(Models.Category.getQuery(.joinedSubcaategoriesServingStyles(false)))
                .single()
                .execute()
                .value

            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    func addServingStyle(categoryId: Int, servingStyleId: Int) async -> Result<Void, Error> {
        do {
            try await client
                .from(.servingStyles)
                .insert(Category.NewServingStyleRequest(categoryId: categoryId, servingStyleId: servingStyleId))
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func deleteServingStyle(categoryId: Int, servingStyleId: Int) async -> Result<Void, Error> {
        do {
            try await client
                .from(.servingStyles)
                .delete()
                .eq("category_id", value: categoryId)
                .eq("serving_style_id", value: servingStyleId)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
