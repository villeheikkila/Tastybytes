import Models

public protocol CategoryRepository {
    func getAllWithSubcategoriesServingStyles() async
        -> Result<[Models.Category.JoinedSubcategoriesServingStyles], Error>
    func insert(newCategory: Category.NewRequest) async -> Result<Void, Error>
    func addServingStyle(categoryId: Int, servingStyleId: Int) async -> Result<Void, Error>
    func deleteServingStyle(categoryId: Int, servingStyleId: Int) async -> Result<Void, Error>
}
