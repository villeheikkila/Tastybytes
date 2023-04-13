import SwiftUI

struct CategoryServingStyleSheet: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var hapticManager: HapticManager
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
    }), trailing: RouterLink(
      sheet: .servingStyleManagement(pickedServingStyles: $viewModel.servingStyles, onSelect: { servingStyle in
        await viewModel.addServingStyleToCategory(servingStyle)
      }),
      label: {
        Label("Add Barcode", systemImage: "plus").bold()
      }
    ))
    .confirmationDialog(
      "Are you sure you want to delete the serving style? The serving style information for affected check-ins will be permanently lost",
      isPresented: $viewModel.showDeleteServingStyleConfirmation,
      titleVisibility: .visible,
      presenting: viewModel.toDeleteServingStyle
    ) { presenting in
      ProgressButton(
        "Remove \(presenting.name) from \(viewModel.category.name)",
        role: .destructive,
        action: {
          await viewModel.deleteServingStyle(onDelete: {
            hapticManager.trigger(.notification(.success))
          })
        }
      )
    }
  }
}
