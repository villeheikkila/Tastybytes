import SwiftUI

struct ProductScreenView: View {
  @StateObject private var viewModel = ViewModel()
  @EnvironmentObject private var profileManager: ProfileManager
  @State private var scrollToTop: Int = 0
  @State private var resetView: Int = 0

  let product: Product.Joined

  var body: some View {
    CheckInListView(fetcher: .product(product), scrollToTop: $scrollToTop, resetView: $resetView) {
      productInfo
      if let summary = viewModel.summary, summary.averageRating != nil {
        Section {
          SummaryView(summary: summary)
        }
      }
    }
    .task {
      viewModel.loadProductSummary(product)
    }
    .navigationBarItems(
      trailing: Button(action: {
        viewModel.setActiveSheet(.checkIn)
      }) { Text("Check-in!").bold() }
        .disabled(!profileManager.hasPermission(.canCreateCheckIns))
    )
    .sheet(item: $viewModel.activeSheet) { sheet in
      NavigationStack {
        switch sheet {
        case .checkIn:
          CheckInSheetView(product: product, onCreation: {
            _ in resetView += 1 // TODO: get rid of this hack 29.1.2023
          })
        case .editSuggestion:
          ProductSheetView(mode: .editSuggestion, initialProduct: product)
        case .editProduct:
          ProductSheetView(mode: .edit, initialProduct: product, onEdit: {
            viewModel.activeSheet = nil
          })
        }
      }
    }
    .confirmationDialog("Delete Product Confirmation",
                        isPresented: $viewModel.showDeleteProductConfirmationDialog,
                        presenting: product) { presenting in
      Button(
        "Delete \(presenting.getDisplayName(.fullName)) Product",
        role: .destructive,
        action: { viewModel.deleteProduct(presenting)
        }
      )
    }
  }

  private var productInfo: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(product.getDisplayName(.fullName))
          .font(.system(size: 18, weight: .bold, design: .default))
          .foregroundColor(.primary)

        if let description = product.description {
          Text(description)
            .font(.system(size: 12, weight: .medium, design: .default))
        }

        HStack {
          NavigationLink(value: Route.company(product.subBrand.brand.brandOwner)) {
            Text(product.getDisplayName(.brandOwner))
              .font(.system(size: 16, weight: .bold, design: .default))
              .foregroundColor(.secondary)
          }
        }

        HStack {
          CategoryNameView(category: product.category)

          ForEach(product.subcategories, id: \.id) { subcategory in
            ChipView(title: subcategory.name, cornerRadius: 5)
          }
        }
      }.padding([.leading, .trailing], 10)
      Spacer()
    }
    .contextMenu {
      ShareLink("Share", item: NavigatablePath.product(id: product.id).url)

      if profileManager.hasPermission(.canEditCompanies) {
        Button(action: {
          viewModel.setActiveSheet(.editProduct)
        }) {
          Label("Edit", systemImage: "pencil")
        }
      } else {
        Button(action: {
          viewModel.setActiveSheet(.editSuggestion)
        }) {
          Label("Edit Suggestion", systemImage: "pencil")
        }
      }

      if profileManager.hasPermission(.canDeleteProducts) {
        Divider()
        Button(action: {
          viewModel.showDeleteConfirmation()
        }) {
          Label("Delete", systemImage: "trash.fill")
            .disabled(product.isVerified)
        }
      }
    }
  }
}

extension ProductScreenView {
  enum Sheet: Identifiable {
    var id: Self { self }
    case checkIn
    case editSuggestion
    case editProduct
  }

  @MainActor class ViewModel: ObservableObject {
    @Published var activeSheet: Sheet?
    @Published var summary: Summary?
    @Published var showDeleteProductConfirmationDialog = false

    func setActiveSheet(_ sheet: Sheet) {
      activeSheet = sheet
    }

    func showDeleteConfirmation() {
      showDeleteProductConfirmationDialog.toggle()
    }

    func loadProductSummary(_ product: Product.Joined) {
      Task {
        switch await repository.product.getSummaryById(id: product.id) {
        case let .success(summary):
          self.summary = summary
        case let .failure(error):
          print(error)
        }
      }
    }

    func deleteProduct(_ product: Product.Joined) {
      Task {
        switch await repository.product.delete(id: product.id) {
        case .success:
          print("TODO HANDLE THIS!!")
        case let .failure(error):
          print(error)
        }
      }
    }
  }
}
