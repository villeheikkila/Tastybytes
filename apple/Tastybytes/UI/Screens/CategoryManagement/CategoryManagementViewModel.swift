import SwiftUI

extension CategoryManagementScreen {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "CategoryManagementScreen")

    let client: Client
    @Published var categories = [Category.JoinedSubcategoriesServingStyles]()
    @Published var verifySubcategory: Subcategory?
    @Published var deleteSubcategory: Subcategory? {
      didSet {
        showDeleteSubcategoryConfirmation = true
      }
    }

    @Published var showDeleteSubcategoryConfirmation = false

    init(_ client: Client) {
      self.client = client
    }

    func verifySubcategory(_ subcategory: Subcategory, isVerified: Bool) async {
      switch await client.subcategory.verification(id: subcategory.id, isVerified: isVerified) {
      case .success:
        await loadCategories()
      case let .failure(error):
        logger
          .error(
            "failed to \(isVerified ? "unverify" : "verify") subcategory \(subcategory.id): \(error.localizedDescription)"
          )
      }
    }

    func saveEditSubcategoryChanges(subCategory: Subcategory, newName: String) async {
      switch await client.subcategory
        .update(updateRequest: Subcategory
          .UpdateRequest(id: subCategory.id, name: newName))
      {
      case .success:
        await loadCategories()
      case let .failure(error):
        logger
          .error(
            "failed to update subcategory \(subCategory.id): \(error.localizedDescription)"
          )
      }
    }

    func deleteSubcategory() async {
      guard let deleteSubcategory else { return }
      switch await client.subcategory.delete(id: deleteSubcategory.id) {
      case .success:
        await loadCategories()
      case let .failure(error):
        logger.error("failed to delete subcategory \(deleteSubcategory.name): \(error.localizedDescription)")
      }
    }

    func addCategory(name: String) async {
      switch await client.category.insert(newCategory: Category.NewRequest(name: name)) {
      case .success:
        await loadCategories()
      case let .failure(error):
        logger
          .error(
            "failed to add new category with name \(name): \(error.localizedDescription)"
          )
      }
    }

    func addSubcategory(category: Category.JoinedSubcategoriesServingStyles, name: String) async {
      switch await client.subcategory
        .insert(newSubcategory: Subcategory
          .NewRequest(name: name, category: category))
      {
      case .success:
        await loadCategories()
      case let .failure(error):
        logger.error("failed to create subcategory '\(name)' to category \(category.name): \(error.localizedDescription)")
      }
    }

    func loadCategories() async {
      switch await client.category.getAllWithSubcategoriesServingStyles() {
      case let .success(categories):
        self.categories = categories
      case let .failure(error):
        logger.error("failed to load categories: \(error.localizedDescription)")
      }
    }
  }
}
