import SwiftUI
import Observation
import OSLog

@Observable
final class AppDataManager {
  private let logger = Logger(category: "AppDataManager")
  var categories = [Category.JoinedSubcategoriesServingStyles]()
  var flavors = [Flavor]()
  var aboutPage: AboutPage? = nil

  private let repository: Repository
  private let feedbackManager: FeedbackManager

  init(repository: Repository, feedbackManager: FeedbackManager) {
    self.repository = repository
    self.feedbackManager = feedbackManager
  }

  var isInitialized: Bool {
    !flavors.isEmpty || !categories.isEmpty
  }

  func initialize() async {
    logger.info("initializing app data")
    async let aboutPagePromise = repository.document.getAboutPage()
    async let flavorPromise = repository.flavor.getAll()
    async let categoryPromise = repository.category.getAllWithSubcategoriesServingStyles()

    switch await flavorPromise {
    case let .success(flavors):
        await MainActor.run {
            withAnimation {
                self.flavors = flavors
            }
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("fetching flavors failed: \(error.localizedDescription)")
    }

    switch await categoryPromise {
    case let .success(categories):
        await MainActor.run {
            self.categories = categories
        }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to load categories: \(error.localizedDescription)")
    }

    switch await aboutPagePromise {
    case let .success(aboutPage):
        await MainActor.run {
            self.aboutPage = aboutPage
        }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("fetching about page failed: \(error.localizedDescription)")
    }
  }

  // Flavors
  func addFlavor(name: String) async {
    switch await repository.flavor.insert(newFlavor: Flavor.NewRequest(name: name)) {
    case let .success(newFlavor):
        await MainActor.run {
            withAnimation {
                flavors.append(newFlavor)
            }
        }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to delete flavor: \(error.localizedDescription)")
    }
  }

  func deleteFlavor(_ flavor: Flavor) async {
    switch await repository.flavor.delete(id: flavor.id) {
    case .success:
        await MainActor.run {
            withAnimation {
                flavors.remove(object: flavor)
            }
        }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
        feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to delete flavor: \(error.localizedDescription)")
    }
  }

  func refreshFlavors() async {
    switch await repository.flavor.getAll() {
    case let .success(flavors):
        await MainActor.run {
            withAnimation {
                self.flavors = flavors
            }
        }
        feedbackManager.trigger(.notification(.success))
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("fetching flavors failed: \(error.localizedDescription)")
    }
  }

  // Categories
  func verifySubcategory(_ subcategory: Subcategory, isVerified: Bool) async {
    switch await repository.subcategory.verification(id: subcategory.id, isVerified: isVerified) {
    case .success:
      await loadCategories()
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger
        .error("failed to \(isVerified ? "unverify" : "verify") subcategory \(subcategory.id): \(error.localizedDescription)")
    }
  }

  func saveEditSubcategoryChanges(subCategory: SubcategoryProtocol, newName: String) async {
    switch await repository.subcategory
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
    switch await repository.subcategory.delete(id: deleteSubcategory.id) {
    case .success:
      await loadCategories()
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to delete subcategory \(deleteSubcategory.name): \(error.localizedDescription)")
    }
  }

  func addCategory(name: String) async {
    switch await repository.category.insert(newCategory: Category.NewRequest(name: name)) {
    case .success:
      await loadCategories()
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to add new category with name \(name): \(error.localizedDescription)")
    }
  }

  func addSubcategory(category: Category.JoinedSubcategoriesServingStyles, name: String) async {
    switch await repository.subcategory
      .insert(newSubcategory: Subcategory
        .NewRequest(name: name, category: category))
    {
    case let .success(newSubcategory):
        await MainActor.run {
            let updatedCategory = category.appending(subcategory: newSubcategory)
            categories.replace(category, with: updatedCategory)
        }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to create subcategory '\(name)' to category \(category.name): \(error.localizedDescription)")
    }
  }

  func loadCategories() async {
    switch await repository.category.getAllWithSubcategoriesServingStyles() {
    case let .success(categories):
        await MainActor.run {
            self.categories = categories
        }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to load categories: \(error.localizedDescription)")
    }
  }
}
