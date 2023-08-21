import Models
import Observation
import OSLog
import Repositories
import SwiftUI

@Observable
final class AppDataManager {
    private let logger = Logger(category: "AppDataManager")
    var categories = [Models.Category.JoinedSubcategoriesServingStyles]()
    var flavors = [Flavor]()
    var aboutPage: AboutPage? = nil

    private let repository: Repository
    private let feedbackManager: FeedbackManager

    init(repository: Repository, feedbackManager: FeedbackManager) {
        self.repository = repository
        self.feedbackManager = feedbackManager
    }

    func initialize(reset: Bool = false) async {
        guard reset || flavors.isEmpty || categories.isEmpty else { return }
        logger.notice("Initializing app data")
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
            logger.notice("App data (flavors) initialized")
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Fetching flavors failed. Error: \(error) (\(#file):\(#line))")
        }

        switch await categoryPromise {
        case let .success(categories):
            await MainActor.run {
                self.categories = categories
            }
            logger.notice("App data (categories) initialized")
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to load categories. Error: \(error) (\(#file):\(#line))")
        }

        switch await aboutPagePromise {
        case let .success(aboutPage):
            await MainActor.run {
                self.aboutPage = aboutPage
            }
            logger.notice("App data (about page) initialized")
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Fetching about page failed. Error: \(error) (\(#file):\(#line))")
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
            logger.error("Failed to delete flavor. Error: \(error) (\(#file):\(#line))")
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
            logger.error("Failed to delete flavor: '\(flavor.id)'. Error: \(error) (\(#file):\(#line))")
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
            logger.error("Fetching flavors failed. Error: \(error) (\(#file):\(#line))")
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
                .error(
                    "Failed to \(isVerified ? "unverify" : "verify") subcategory \(subcategory.id). error: \(error)"
                )
        }
    }

    func deleteSubcategory(_ deleteSubcategory: SubcategoryProtocol) async {
        switch await repository.subcategory.delete(id: deleteSubcategory.id) {
        case .success:
            await loadCategories()
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to delete subcategory \(deleteSubcategory.name). Error: \(error) (\(#file):\(#line))")
        }
    }

    func addCategory(name: String) async {
        switch await repository.category.insert(newCategory: Models.Category.NewRequest(name: name)) {
        case .success:
            await loadCategories()
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to add new category with name \(name). Error: \(error) (\(#file):\(#line))")
        }
    }

    func addSubcategory(category: Models.Category.JoinedSubcategoriesServingStyles, name: String) async {
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
            logger
                .error(
                    "Failed to create subcategory '\(name)' to category \(category.name). Error: \(error) (\(#file):\(#line))"
                )
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
            logger.error("Failed to load categories. Error: \(error) (\(#file):\(#line))")
        }
    }
}
