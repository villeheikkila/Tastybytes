import Models

public protocol CategoryRepository: Sendable {
    func getAllWithSubcategoriesServingStyles() async throws -> [Models.Category.JoinedSubcategoriesServingStyles]
    func insert(newCategory: Category.NewRequest) async throws -> Models.Category.JoinedSubcategoriesServingStyles
    func addServingStyle(categoryId: Int, servingStyleId: Int) async throws
    func deleteCategory(id: Int) async throws
    func deleteServingStyle(categoryId: Int, servingStyleId: Int) async throws
}
