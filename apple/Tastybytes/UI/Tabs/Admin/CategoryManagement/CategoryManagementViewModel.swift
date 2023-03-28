import SwiftUI

extension CategoryManagementScreen {
  enum Sheet: Identifiable {
    var id: Self { self }
    case addCategory
    case addSubcategory
    case editSubcategory
    case editServingStyles
  }

  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "CategoryManagementScreen")

    let client: Client
    @Published var categories = [Category.JoinedSubcategoriesServingStyles]()
    @Published var activeSheet: Sheet?
    @Published var toAddSubcategory: Category.JoinedSubcategoriesServingStyles? {
      didSet {
        if toAddSubcategory != nil {
          activeSheet = .addSubcategory
        } else {
          newSubcategoryName = ""
        }
      }
    }

    @Published var newSubcategoryName = ""
    @Published var verifySubcategory: Subcategory?
    @Published var editSubcategory: Subcategory? {
      didSet {
        activeSheet = .editSubcategory
        editSubcategoryName = editSubcategory?.name ?? ""
      }
    }

    @Published var editSubcategoryName: String = ""

    @Published var deleteSubcategory: Subcategory? {
      didSet {
        showDeleteSubcategoryConfirmation = true
      }
    }

    @Published var showDeleteSubcategoryConfirmation = false
    @Published var editServingStyle: Category.JoinedSubcategoriesServingStyles? {
      didSet {
        activeSheet = .editServingStyles
      }
    }

    @Published var newCategoryName = ""

    init(_ client: Client) {
      self.client = client
    }

    func verifySubcategory(_ subcategory: Subcategory, isVerified: Bool) {
      Task {
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
    }

    func saveEditSubcategoryChanges() {
      guard let editSubcategory else { return }
      Task {
        switch await client.subcategory
          .update(updateRequest: Subcategory
            .UpdateRequest(id: editSubcategory.id, name: editSubcategoryName))
        {
        case .success:
          await loadCategories()
          activeSheet = nil
        case let .failure(error):
          logger
            .error(
              "failed to update subcategory \(editSubcategory.id): \(error.localizedDescription)"
            )
        }
      }
    }

    func deleteSubcategories() {
      guard let deleteSubcategory else { return }
      Task {
        switch await client.subcategory.delete(id: deleteSubcategory.id) {
        case .success:
          await loadCategories()
        case let .failure(error):
          logger
            .error("failed to delete subcategory \(deleteSubcategory.name): \(error.localizedDescription)")
        }
      }
    }

    func addCategory() {
      Task {
        switch await client.category.insert(newCategory: Category.NewRequest(name: newCategoryName)) {
        case .success:
          await loadCategories()
        case let .failure(error):
          logger
            .error(
              "failed to add new category with name \(self.newCategoryName): \(error.localizedDescription)"
            )
        }
      }
    }

    func addSubcategory() {
      guard let toAddSubcategory else { return }
      Task {
        switch await client.subcategory
          .insert(newSubcategory: Subcategory
            .NewRequest(name: newSubcategoryName, category: toAddSubcategory))
        {
        case .success:
          await loadCategories()
        case let .failure(error):
          logger
            .error(
              "failed to create subcategory '\(self.newCategoryName)' to category \(toAddSubcategory.name): \(error.localizedDescription)"
            )
        }
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
