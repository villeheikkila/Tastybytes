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
            }
            .swipeActions {
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
    .refreshable {
        await viewModel.loadCategories() 
    }
    .sheet(item: $viewModel.activeSheet) { sheet in
      NavigationStack {
        switch sheet {
        case .editServingStyles:
          if let editServingStyle = viewModel.editServingStyle {
            CategoryServingStyleSheet(viewModel.client, category: editServingStyle)
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
