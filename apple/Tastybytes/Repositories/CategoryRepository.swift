import Foundation
import Supabase

protocol CategoryRepository {
  func getAllWithSubcategories() async -> Result<[Category.JoinedSubcategories], Error>
  func getServingStylesByCategory(categoryId: Int) async -> Result<Category.JoinedServingStyles, Error>
}

struct SupabaseCategoryRepository: CategoryRepository {
  let client: SupabaseClient

  func getAllWithSubcategories() async -> Result<[Category.JoinedSubcategories], Error> {
    do {
      let response: [Category.JoinedSubcategories] = try await client
        .database
        .from(Category.getQuery(.tableName))
        .select(columns: Category.getQuery(.joinedSubcategories(false)))
        .order(column: "name")
        .execute()
        .value

      return .success(response)
    } catch {
      return .failure(error)
    }
  }

  func getServingStylesByCategory(categoryId: Int) async -> Result<Category.JoinedServingStyles, Error> {
    do {
      let response: Category.JoinedServingStyles = try await client
        .database
        .from(Category.getQuery(.tableName))
        .select(columns: Category.getQuery(.joinedServingStyles(false)))
        .eq(column: "id", value: categoryId)
        .limit(count: 1)
        .single()
        .execute()
        .value

      return .success(response)
    } catch {
      return .failure(error)
    }
  }
}
