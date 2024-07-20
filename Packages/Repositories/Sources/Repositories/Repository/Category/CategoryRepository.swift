import Models

public protocol CategoryRepository: Sendable {
    func getAllWithSubcategoriesServingStyles() async throws -> [Models.Category.JoinedSubcategoriesServingStyles]
    func getDetailed(id: Category.Id) async throws -> Category.Detailed
    func insert(newCategory: Category.NewRequest) async throws -> Models.Category.JoinedSubcategoriesServingStyles
    func addServingStyle(categoryId: Category.Id, servingStyleId: ServingStyle.Id) async throws
    func deleteCategory(id: Category.Id) async throws
    func deleteServingStyle(categoryId: Category.Id, servingStyleId: ServingStyle.Id) async throws
}
