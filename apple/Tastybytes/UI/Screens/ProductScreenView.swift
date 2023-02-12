import SwiftUI

struct ProductScreenView: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var router: Router
  @State private var scrollToTop: Int = 0

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
      }
    }
    .task {
      viewModel.refresh()
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
          ProductSheetView(viewModel.client, mode: .editSuggestion, initialProduct: viewModel.product)
        case .editProduct:
          ProductSheetView(viewModel.client, mode: .edit, initialProduct: viewModel.product, onEdit: {
            viewModel.onEditCheckIn()
          })
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
          NavigationLink(value: Route.company(viewModel.product.subBrand.brand.brandOwner)) {
            Text(viewModel.product.getDisplayName(.brandOwner))
              .font(.system(size: 16, weight: .bold, design: .default))
              .foregroundColor(.secondary)
          }
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
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Menu {
        Button(action: {
          viewModel.setActiveSheet(.checkIn)
        }) {
          Text("Check-in!").bold(
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

extension ProductScreenView {
  enum Sheet: Identifiable {
    var id: Self { self }
    case checkIn
    case barcodes
    case editSuggestion
    case editProduct
    case barcodeScanner
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProductScreenView")
    let client: Client
    @Published var product: Product.Joined
    @Published var activeSheet: Sheet?
    @Published var summary: Summary?
    @Published var showDeleteProductConfirmationDialog = false
    @Published var showUnverifyProductConfirmation = false
    @Published var resetView: Int = 0

    init(_ client: Client, product: Product.Joined) {
      self.product = product
      self.client = client
    }

    func setActiveSheet(_ sheet: Sheet) {
      activeSheet = sheet
    }

    func showDeleteConfirmation() {
      showDeleteProductConfirmationDialog.toggle()
    }

    func onEditCheckIn() {
      activeSheet = nil
      refresh()
      refreshCheckIns()
    }

    func refresh() {
      Task {
        async let productPromise = client.product.getById(id: product.id)
        async let summaryPromise = client.product.getSummaryById(id: product.id)

        switch await productPromise {
        case let .success(refreshedProduct):
          withAnimation {
            product = refreshedProduct
          }
        case let .failure(error):
          logger.error("failed to refresh product by id '\(self.product.id)': \(error.localizedDescription)")
        }

        switch await summaryPromise {
        case let .success(summary):
          self.summary = summary
        case let .failure(error):
          logger.error("failed to load product summary for '\(self.product.id)': \(error.localizedDescription)")
        }
      }
    }

    func addBarcodeToProduct(barcode: Barcode, onComplete: @escaping () -> Void) {
      Task {
        switch await client.productBarcode.addToProduct(product: product, barcode: barcode) {
        case .success:
          onComplete()
        case let .failure(error):
          logger
            .error(
              "adding barcode \(barcode.barcode) to product \(self.product.id) failed: \(error.localizedDescription)"
            )
        }
      }
    }

    func refreshCheckIns() {
      refresh()
      resetView += 1 // TODO: get rid of this hack 29.1.2023
    }

    func verifyProduct(isVerified: Bool) {
      Task {
        switch await client.product.verification(id: product.id, isVerified: isVerified) {
        case .success:
          refresh()
        case let .failure(error):
          logger.error("failed to verify product \(self.product.id): \(error.localizedDescription)")
        }
      }
    }

    func deleteProduct(onDelete: @escaping () -> Void) {
      Task {
        switch await client.product.delete(id: product.id) {
        case .success:
          onDelete()
        case let .failure(error):
          logger.error("failed to delete product \(self.product.id): \(error.localizedDescription)")
        }
      }
    }
  }
}
