import SwiftUI

struct CategoryServingStyleSheet: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var router: Router
  @Environment(\.dismiss) private var dismiss

  init(_ client: Client, category: Category.JoinedSubcategoriesServingStyles) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, category: category))
  }

  var body: some View {
    List {
      ForEach(viewModel.servingStyles) { servingStyle in
        HStack {
          Text(servingStyle.label)
        }
        .swipeActions {
          Button(role: .destructive, action: { viewModel.toDeleteServingStyle = servingStyle }, label: {
            Label("Delete", systemImage: "trash")
          })
        }
      }
    }
    .navigationTitle("\(viewModel.category.name) Serving Styles")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarItems(leading: Button(role: .cancel, action: { dismiss() }, label: {
      Text("Done").bold()
    }), trailing: Button(
      action: {
        router.navigate(sheet: .servingStyleManagement(pickedServingStyles: $viewModel.servingStyles, onSelect: { servingStyle in
          viewModel.addServingStyleToCategory(servingStyle)
        }))
      },
      label: {
        Label("Add Barcode", systemImage: "plus").bold()
      }
    ))
    .confirmationDialog("Delete Serving Style",
                        isPresented: $viewModel.showDeleteServingStyleConfirmation,
                        presenting: viewModel.toDeleteServingStyle)
    { presenting in
      Button(
        "Remove \(presenting.name) from \(viewModel.category.name)",
        role: .destructive,
        action: {
          viewModel.deleteServingStyle(onDelete: {
            hapticManager.trigger(.notification(.success))
          })
        }
      )
    }
  }
}
