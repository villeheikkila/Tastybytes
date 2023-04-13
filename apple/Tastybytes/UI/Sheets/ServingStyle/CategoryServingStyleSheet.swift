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
          Button("Delete", systemImage: "trash", role: .destructive, action: { viewModel.toDeleteServingStyle = servingStyle })
        }
      }
    }
    .navigationTitle("\(viewModel.category.name) Serving Styles")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarItems(leading: Button("Done", role: .cancel, action: { dismiss() }).bold(),
                        trailing: RouterLink("Add Barcode", systemImage: "plus",
                                             sheet: .servingStyleManagement(
                                               pickedServingStyles: $viewModel.servingStyles,
                                               onSelect: { servingStyle in
                                                 await viewModel.addServingStyleToCategory(servingStyle)
                                               }
                                             )).bold())
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
