import SwiftUI

struct CategoryManagementScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var router: Router

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    List {
      ForEach(viewModel.categories) { category in
        Section {
          ForEach(category.subcategories) { subcategory in
            HStack {
              Text(subcategory.name)
            }
            .swipeActions {
              ProgressButton(
                action: { await viewModel.verifySubcategory(subcategory, isVerified: !subcategory.isVerified) },
                label: {
                  if subcategory.isVerified {
                    Label("Unverify", systemImage: "x.square")
                  } else {
                    Label("Verify", systemImage: "checkmark")
                  }
                }
              ).tint(subcategory.isVerified ? .yellow : .green)
              RouteLink(sheet: .editSubcategory(subcategory: subcategory, onSubmit: { newName in
                Task { await viewModel.saveEditSubcategoryChanges(subCategory: subcategory, newName: newName) }
              }), label: {
                Label("Edit", systemImage: "pencil")
              }).tint(.yellow)
              Button(role: .destructive, action: { viewModel.deleteSubcategory = subcategory }, label: {
                Label("Delete", systemImage: "trash")
              })
            }
          }
        } header: {
          HStack {
            Text(category.name)
            Spacer()
            Menu {
              RouteLink(sheet: .categoryServingStyle(category: category), label: {
                Label("Edit Serving Styles", systemImage: "pencil")
              })
              RouteLink(sheet: .addSubcategory(category: category, onSubmit: { newSubcategoryName in
                Task { await viewModel.addSubcategory(category: category, name: newSubcategoryName) }
              }), label: {
                Label("Add Subcategory", systemImage: "plus")
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
    .navigationBarTitle("Categories")
    .navigationBarItems(trailing: RouteLink(sheet: .addCategory(onSubmit: { newCategoryName in
      Task { await viewModel.addCategory(name: newCategoryName) }
    }), label: {
      Label("Add Category", systemImage: "plus")
        .labelStyle(.iconOnly)
        .bold()
    }))
    .refreshable {
      await hapticManager.wrapWithHaptics {
        await viewModel.loadCategories()
      }
    }
    .confirmationDialog("Are you sure you want to delete subcategory?",
                        isPresented: $viewModel.showDeleteSubcategoryConfirmation,
                        titleVisibility: .visible,
                        presenting: viewModel.deleteSubcategory)
    { presenting in
      ProgressButton(
        "Delete \(presenting.name)",
        role: .destructive,
        action: { await viewModel.deleteSubcategory() }
      )
    }
    .task {
      await viewModel.loadCategories()
    }
  }
}
