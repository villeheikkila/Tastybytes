import SwiftUI

struct CategoryManagementScreen: View {
  private let logger = getLogger(category: "CategoryManagementScreen")
  @EnvironmentObject private var client: AppClient
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var appDataManager: AppDataManager
  @EnvironmentObject private var toastManager: ToastManager
  @State private var showDeleteSubcategoryConfirmation = false
  @State private var verifySubcategory: Subcategory?
  @State private var deleteSubcategory: Subcategory? {
    didSet {
      showDeleteSubcategoryConfirmation = true
    }
  }

  var body: some View {
    List {
      ForEach(appDataManager.categories) { category in
        Section {
          ForEach(category.subcategories) { subcategory in
            HStack {
              Text(subcategory.name)
            }
          }
        } header: {
          HStack {
            Text(category.name)
            Spacer()
            Menu {
              RouterLink("Edit Serving Styles", systemImage: "pencil", sheet: .categoryServingStyle(category: category))
              RouterLink(
                "Add Subcategory",
                systemImage: "plus",
                sheet: .addSubcategory(category: category, onSubmit: { newSubcategoryName in
                  await appDataManager.addSubcategory(category: category, name: newSubcategoryName)
                })
              )
            } label: {
              Label("Options menu", systemImage: "ellipsis")
                .labelStyle(.iconOnly)
                .frame(width: 24, height: 24)
            }
          }
        }.headerProminence(.increased)
      }
    }
    .navigationBarTitle("Categories")
    .navigationBarItems(trailing: RouterLink("Add Category", systemImage: "plus",
                                             sheet: .addCategory(onSubmit: { _ in
                                               toastManager.toggle(.success("Category created!"))
                                             }))
                                             .labelStyle(.iconOnly)
                                             .bold())
    .refreshable {
      await hapticManager.wrapWithHaptics {
        await appDataManager.initialize()
      }
    }
    .confirmationDialog("Are you sure you want to delete subcategory?",
                        isPresented: $showDeleteSubcategoryConfirmation,
                        titleVisibility: .visible,
                        presenting: deleteSubcategory)
    { presenting in
      ProgressButton(
        "Delete \(presenting.name)",
        role: .destructive,
        action: { await appDataManager.deleteSubcategory(presenting) }
      )
    }
  }
}
