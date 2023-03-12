import SwiftUI

struct CategoryManagementScreen: View {
  @StateObject private var viewModel: ViewModel

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    List {
      ForEach(viewModel.categories) { category in
        Section {
          ForEach(category.subcategories) { subcategory in
            HStack {
              Text(subcategory.label)
            }.swipeActions {
              Button(
                action: { viewModel.verifySubcategory(subcategory, isVerified: !subcategory.isVerified) },
                label: {
                  if subcategory.isVerified {
                    Label("Unverify", systemImage: "x.square")
                  } else {
                    Label("Verify", systemImage: "checkmark")
                  }
                }
              ).tint(subcategory.isVerified ? .yellow : .green)
              Button(action: { viewModel.editSubcategory = subcategory }, label: {
                Label("Edit", systemImage: "pencil")
              }).tint(.yellow)
              Button(role: .destructive, action: { viewModel.deleteSubcategory = subcategory }, label: {
                Label("Delete", systemImage: "trash")
              })
            }
          }
        } header: {
          HStack {
            Text(category.label)
            Spacer()
            Menu {
              Button(action: { viewModel.editServingStyle = category }, label: {
                Label("Edit Serving Styles", systemImage: "pencil")
              })
            } label: {
              Label("Options menu", systemImage: "ellipsis")
                .labelStyle(.iconOnly)
                .frame(width: 24, height: 24)
            }
          }
        }.headerProminence(.increased)
      }
    }
    .sheet(item: $viewModel.activeSheet) { sheet in
      NavigationStack {
        switch sheet {
        case .editServingStyles:
          if let editServingStyle = viewModel.editServingStyle {
            DismissableSheet(title: "Edit serving styles for \(editServingStyle.label)") {
              List {
                ForEach(editServingStyle.servingStyles) { servingStyle in
                  HStack {
                    Text(servingStyle.label)
                  }
                }
              }
            }
          }
        case .editSubcategory:
          if let editSubcategory = viewModel.editSubcategory {
            DismissableSheet(title: "Edit \(editSubcategory.label)") {
              Form {
                TextField("Name", text: $viewModel.editSubcategoryName)
                Button(
                  action: { viewModel.saveEditSubcategoryChanges() },
                  label: { Text("Save changes").disabled(editSubcategory.name == viewModel.editSubcategoryName) }
                )
              }
            }
          }
        }
      }.if(sheet == .editSubcategory, transform: { view in view.presentationDetents([.medium]) })
    }
    .confirmationDialog("Delete Subcategory Confirmation",
                        isPresented: $viewModel.showDeleteSubcategoryConfirmation,
                        presenting: viewModel.deleteSubcategory)
    { presenting in
      Button(
        "Delete \(presenting.label) Subcategory",
        role: .destructive,
        action: { viewModel.deleteSubcategories() }
      )
    }
    .task {
      await viewModel.loadCategories()
    }
  }
}

extension CategoryManagementScreen {
  enum Sheet: Identifiable {
    var id: Self { self }
    case editSubcategory
    case editServingStyles
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "CategoryManagementScreen")

    let client: Client
    @Published var categories = [Category.JoinedSubcategoriesServingStyles]()
    @Published var activeSheet: Sheet?
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
      if let editSubcategory {
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
    }

    func deleteSubcategories() {
      if let deleteSubcategory {
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
