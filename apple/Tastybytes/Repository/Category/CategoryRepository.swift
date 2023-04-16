import Supabase

protocol CategoryRepository {
  func getAllWithSubcategories() async -> Result<[Category.JoinedSubcategories], Error>
  func getAllWithSubcategoriesServingStyles() async -> Result<[Category.JoinedSubcategoriesServingStyles], Error>
  func insert(newCategory: Category.NewRequest) async -> Result<Void, Error>
  func getServingStylesByCategory(categoryId: Int) async -> Result<Category.JoinedServingStyles, Error>
  func addServingStyle(categoryId: Int, servingStyleId: Int) async -> Result<Void, Error>
  func deleteServingStyle(categoryId: Int, servingStyleId: Int) async -> Result<Void, Error>
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

  func getAllWithSubcategoriesServingStyles() async -> Result<[Category.JoinedSubcategoriesServingStyles], Error> {
    do {
      let response: [Category.JoinedSubcategoriesServingStyles] = try await client
        .database
        .from(Category.getQuery(.tableName))
        .select(columns: Category.getQuery(.joinedSubcaategoriesServingStyles(false)))
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

  func insert(newCategory: Category.NewRequest) async -> Result<Void, Error> {
    do {
      try await client
        .database
        .from(Category.getQuery(.tableName))
        .insert(values: newCategory, returning: .representation)
        .execute()

      return .success(())
    } catch {
      return .failure(error)
    }
  }

  func addServingStyle(categoryId: Int, servingStyleId: Int) async -> Result<Void, Error> {
    do {
      try await client
        .database
        .from(Category.getQuery(.servingStyleTableName))
        .insert(values: Category.NewServingStyleRequest(categoryId: categoryId, servingStyleId: servingStyleId))
        .execute()

      return .success(())
    } catch {
      return .failure(error)
    }
  }

  func deleteServingStyle(categoryId: Int, servingStyleId: Int) async -> Result<Void, Error> {
    do {
      try await client
        .database
        .from(Category.getQuery(.servingStyleTableName))
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
