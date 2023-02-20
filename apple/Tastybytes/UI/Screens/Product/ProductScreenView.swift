import SwiftUI

struct ProductScreenView: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var router: Router
  @State private var scrollToTop: Int = 0
  @Environment(\.dismiss) private var dismiss

  init(_ client: Client, product: Product.Joined) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, product: product))
  }

  var body: some View {
    CheckInListView(
      viewModel.client,
      fetcher: .product(viewModel.product),
      scrollToTop: $scrollToTop,
      resetView: $viewModel.resetView,
      onRefresh: {
        viewModel.refresh()
      }
    ) {
      productInfo
      if let summary = viewModel.summary, summary.averageRating != nil {
        Section {
          SummaryView(summary: summary)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 10, trailing: 0))
      }
    }
    .task {
      viewModel.loadSummary()
    }
    .toolbar {
      toolbarContent
    }
    .sheet(item: $viewModel.activeSheet) { sheet in
      NavigationStack {
        switch sheet {
        case .checkIn:
          CheckInSheetView(viewModel.client, product: viewModel.product, onCreation: {
            _ in viewModel.refreshCheckIns()
          })
        case .barcodes:
          BarcodeManagementSheetView(viewModel.client, product: viewModel.product)
        case .editSuggestion:
          DismissableSheet(title: "Edit Suggestion") {
            AddProductView(viewModel.client, mode: .editSuggestion(viewModel.product))
          }
        case .editProduct:
          DismissableSheet(title: "Edit Product") {
            AddProductView(viewModel.client, mode: .edit(viewModel.product), onEdit: {
              viewModel.onEditCheckIn()
            })
          }
        case .barcodeScanner:
          BarcodeScannerSheetView(onComplete: {
            barcode in viewModel.addBarcodeToProduct(barcode: barcode, onComplete: {
              toastManager.toggle(.success("Barcode added"))
            })
          })
        }
      }.if(sheet == .barcodeScanner, transform: { view in view.presentationDetents([.medium]) })
    }
    .confirmationDialog("Unverify Product",
                        isPresented: $viewModel.showUnverifyProductConfirmation,
                        presenting: viewModel.product) { presenting in
      Button("Unverify \(presenting.name) product", role: .destructive, action: {
        viewModel.verifyProduct(isVerified: false)
      })
    }
    .confirmationDialog("Delete Product Confirmation",
                        isPresented: $viewModel.showDeleteProductConfirmationDialog,
                        presenting: viewModel.product) { presenting in
      Button(
        "Delete \(presenting.getDisplayName(.fullName)) Product",
        role: .destructive,
        action: { viewModel.deleteProduct(onDelete: {
          router.removeLast()
        })
        }
      )
    }
  }

  private var productInfo: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(viewModel.product.getDisplayName(.fullName))
          .font(.system(size: 18, weight: .bold, design: .default))
          .foregroundColor(.primary)

        if let description = viewModel.product.description {
          Text(description)
            .font(.system(size: 12, weight: .medium, design: .default))
        }

        HStack {
          Text(viewModel.product.getDisplayName(.brandOwner))
            .font(.system(size: 16, weight: .bold, design: .default))
            .foregroundColor(.secondary)
        }
        .accessibilityAddTraits(.isLink)
        .onTapGesture {
          router.navigate(to: Route.company(viewModel.product.subBrand.brand.brandOwner), resetStack: true)
        }

        HStack {
          CategoryNameView(category: viewModel.product.category)

          ForEach(viewModel.product.subcategories, id: \.id) { subcategory in
            ChipView(title: subcategory.name, cornerRadius: 5)
          }
        }
      }.padding([.leading, .trailing], 10)
      Spacer()
    }
    .listRowSeparator(.hidden)
    .listRowInsets(.init())
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Menu {
        Button(action: {
          viewModel.setActiveSheet(.checkIn)
        }) {
          Label("Check-in", systemImage: "plus").bold(
          )
        }.disabled(!profileManager.hasPermission(.canCreateCheckIns))

        ShareLink("Share", item: NavigatablePath.product(id: viewModel.product.id).url)

        if profileManager.hasPermission(.canAddBarcodes) {
          Button(action: {
            viewModel.setActiveSheet(.barcodeScanner)
          }) {
            Label("Add Barcode", systemImage: "barcode.viewfinder")
          }
        }
        Divider()

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

        if viewModel.product.isVerified {
          Button(action: {
            viewModel.showUnverifyProductConfirmation = true
          }) {
            Label("Verified", systemImage: "checkmark.circle")
          }
        } else if profileManager.hasPermission(.canVerify) {
          Button(action: {
            viewModel.verifyProduct(isVerified: true)
          }) {
            Label("Verify", systemImage: "checkmark")
          }
        } else {
          Label("Not verified", systemImage: "x.circle")
        }

        if profileManager.hasPermission(.canDeleteBarcodes) {
          Button(action: {
            viewModel.setActiveSheet(.barcodes)
          }) {
            Label("Barcodes", systemImage: "barcode")
          }
        }

        if profileManager.hasPermission(.canDeleteProducts) {
          Button(action: {
            viewModel.showDeleteConfirmation()
          }) {
            Label("Delete", systemImage: "trash.fill")
          }
          .disabled(viewModel.product.isVerified)
        }
      } label: {
        Image(systemName: "ellipsis")
      }
    }
  }
}
