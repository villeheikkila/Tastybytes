import SwiftUI

@MainActor
class AppDataManager: ObservableObject {
  private let logger = getLogger(category: "AppDataManager")
  @Published var categories = [Category.JoinedSubcategoriesServingStyles]()
  @Published var flavors = [Flavor]()

  let client: Client

  init(client: Client) {
    self.client = client
  }

  func initialize() async {
    async let flavorPromise = client.flavor.getAll()
    async let categoryPromise = client.category.getAllWithSubcategoriesServingStyles()

    switch await flavorPromise {
    case let .success(flavors):
      withAnimation {
        self.flavors = flavors
      }
    case let .failure(error):
      logger.error("fetching flavors failed: \(error.localizedDescription)")
    }

    switch await categoryPromise {
    case let .success(categories):
      self.categories = categories
    case let .failure(error):
      logger.error("failed to load categories: \(error.localizedDescription)")
    }
  }

  // Flavors
  func addFlavor(name: String) async {
    switch await client.flavor.insert(newFlavor: Flavor.NewRequest(name: name)) {
    case let .success(newFlavor):
      withAnimation {
        flavors.append(newFlavor)
      }
    case let .failure(error):
      logger.error("failed to delete flavor: \(error.localizedDescription)")
    }
  }

  func deleteFlavor(_ flavor: Flavor) async {
    switch await client.flavor.delete(id: flavor.id) {
    case .success:
      withAnimation {
        flavors.remove(object: flavor)
      }
    case let .failure(error):
      logger.error("failed to delete flavor: \(error.localizedDescription)")
    }
  }

  func loadFlavors() async {
    switch await client.flavor.getAll() {
    case let .success(flavors):
      withAnimation {
        self.flavors = flavors
      }
    case let .failure(error):
      logger.error("fetching flavors failed: \(error.localizedDescription)")
    }
  }

  // Categories
  func verifySubcategory(_ subcategory: Subcategory, isVerified: Bool) async {
    switch await client.subcategory.verification(id: subcategory.id, isVerified: isVerified) {
    case .success:
      await loadCategories()
    case let .failure(error):
      logger
        .error("failed to \(isVerified ? "unverify" : "verify") subcategory \(subcategory.id): \(error.localizedDescription)")
    }
  }

  func saveEditSubcategoryChanges(subCategory: SubcategoryProtocol, newName: String) async {
    switch await client.subcategory
      .update(updateRequest: Subcategory
        .UpdateRequest(id: subCategory.id, name: newName))
    {
    case .success:
      await loadCategories()
    case let .failure(error):
      logger.error("failed to update subcategory \(subCategory.id): \(error.localizedDescription)")
    }
  }

  func deleteSubcategory(_ deleteSubcategory: SubcategoryProtocol) async {
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
      logger.error("failed to add new category with name \(name): \(error.localizedDescription)")
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
