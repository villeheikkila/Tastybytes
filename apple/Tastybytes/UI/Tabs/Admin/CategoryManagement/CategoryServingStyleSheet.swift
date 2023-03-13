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
    .navigationTitle("\(viewModel.category.label) Serving Styles")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarItems(leading: Button(role: .cancel, action: { dismiss() }, label: {
      Text("Done").bold()
    }), trailing: Button(action: { viewModel.showServingStylePicker = true }, label: {
      Label("Add Barcode", systemImage: "plus").bold()
    }))
    .sheet(isPresented: $viewModel.showServingStylePicker) {
      ServingStyleManagementSheet(
        viewModel.client,
        pickedServingStyles: $viewModel.servingStyles,
        onSelect: { servingStyle in viewModel.addServingStyleToCategory(servingStyle)
        }
      )
    }
    .confirmationDialog("Delete Serving Style",
                        isPresented: $viewModel.showDeleteServingStyleConfirmation,
                        presenting: viewModel.toDeleteServingStyle)
    { presenting in
      Button(
        "Remove \(presenting.name) from \(viewModel.category.label)",
        role: .destructive,
        action: {
          viewModel.deleteServingStyle(onDelete: {
            hapticManager.trigger(of: .notification(.success))
          })
        }
      )
    }
  }
}

extension CategoryServingStyleSheet {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ServingStyleManagementSheet")
    let client: Client
    let category: Category.JoinedSubcategoriesServingStyles
    @Published var servingStyles: [ServingStyle]
    @Published var toDeleteServingStyle: ServingStyle? {
      didSet {
        showDeleteServingStyleConfirmation = true
      }
    }

    @Published var showDeleteServingStyleConfirmation = false
    @Published var showServingStylePicker = false

    init(_ client: Client, category: Category.JoinedSubcategoriesServingStyles) {
      self.client = client
      self.category = category
      servingStyles = category.servingStyles
    }

    func addServingStyleToCategory(_ servingStyle: ServingStyle) {
      Task {
        switch await client.category.addServingStyle(
          categoryId: category.id,
          servingStyleId: servingStyle.id
        ) {
        case .success:
          withAnimation {
            servingStyles.append(servingStyle)
          }
        case let .failure(error):
          logger
            .error(
              "failed to add serving style '\(servingStyle.id) to \(self.category.id) category': \(error.localizedDescription)"
            )
        }
      }
    }

    func deleteServingStyle(onDelete: @escaping () -> Void) {
      if let toDeleteServingStyle {
        Task {
          switch await client.category.deleteServingStyle(
            categoryId: category.id,
            servingStyleId: toDeleteServingStyle.id
          ) {
          case .success:
            withAnimation {
              servingStyles.remove(object: toDeleteServingStyle)
            }
            onDelete()
          case let .failure(error):
            logger
              .error(
                "failed to delete serving style '\(toDeleteServingStyle.id)': \(error.localizedDescription)"
              )
          }
        }
      }
    }
  }
}
