struct SupabaseServingStyleRepository {
  private let database = Supabase.client.database
  private let tableName = "serving_styles"
  private let saved = "id, name"

  func loadByCategoryId(categoryId: Int) async throws -> CategoryServingStyles {
    let d = try await database
      .from("categories")
      .select(columns: "id, serving_styles (id, name)")
      .eq(column: "id", value: categoryId)
      .limit(count: 1)
      .single()
      .execute()

    printData(data: d.data)

    return try d.decoded(to: CategoryServingStyles.self)
  }
}
