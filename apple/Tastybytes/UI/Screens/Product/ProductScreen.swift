import SwiftUI
import OSLog

struct ProductScreen: View {
  private let logger = Logger(category: "ProductScreen")
  @Environment(Repository.self) private var repository
  @Environment(ProfileManager.self) private var profileManager
  @Environment(FeedbackManager.self) private var feedbackManager
  @Environment(Router.self) private var router
  @Environment(\.dismiss) private var dismiss
  @State private var scrollToTop: Int = 0
  @State private var product: Product.Joined
  @State private var summary: Summary?
  @State private var showDeleteProductConfirmationDialog = false
  @State private var showUnverifyProductConfirmation = false
  @State private var resetView: Int = 0

  init(product: Product.Joined) {
    _product = State(wrappedValue: product)
  }

  var body: some View {
    CheckInListView(
      fetcher: .product(product),
      scrollToTop: $scrollToTop,
      onRefresh: {
        await refresh()
      },
      emptyView: {},
      header: {
        Section {
          ProductItemView(product: product, extras: [.companyLink, .logo])
          SummaryView(summary: summary)
          RouterLink("Check-in!", sheet: .newCheckIn(product, onCreation: { _ in
            refreshCheckIns()
          }))
          .fontWeight(.semibold)
          .padding(.all, 8)
          .frame(maxWidth: .infinity)
          .background(Color.accentColor)
          .foregroundColor(.white)
          .cornerRadius(8)
        }
        .listRowSeparator(.hidden)
      }
    )
    .id(resetView)
    .task {
      if summary == nil {
        await loadSummary()
      }
    }
    .toolbar {
      toolbarContent
    }
    .confirmationDialog("Unverify Product",
                        isPresented: $showUnverifyProductConfirmation,
                        presenting: product)
    { presenting in
      ProgressButton("Unverify \(presenting.name) product", role: .destructive, action: {
        await verifyProduct(product: presenting, isVerified: false)
      })
    }
    .confirmationDialog("Are you sure you want to delete the product and all of its check-ins?",
                        isPresented: $showDeleteProductConfirmationDialog,
                        titleVisibility: .visible,
                        presenting: product)
    { presenting in
      ProgressButton(
        "Delete \(presenting.getDisplayName(.fullName))",
        role: .destructive,
        action: { await deleteProduct(presenting) }
      )
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Menu {
        VerificationButton(isVerified: product.isVerified, verify: {
          await verifyProduct(product: product, isVerified: true)
        }, unverify: {
          showUnverifyProductConfirmation = true
        })

        Divider()

        RouterLink("Check-in", systemSymbol: .plus, sheet: .newCheckIn(product, onCreation: { _ in
          refreshCheckIns()
        }))
        .bold()
        .disabled(!profileManager.hasPermission(.canCreateCheckIns))

        ShareLink("Share", item: NavigatablePath.product(id: product.id).url)

        if profileManager.hasPermission(.canAddBarcodes) {
          RouterLink("Add Barcode", systemSymbol: .barcodeViewfinder, sheet: .barcodeScanner(onComplete: { barcode in
            Task { await addBarcodeToProduct(barcode) }
          }))
        }

        Divider()

        if profileManager.hasPermission(.canEditCompanies) {
          RouterLink("Edit", systemSymbol: .pencil, sheet: .productEdit(product: product))
        } else {
          RouterLink("Edit Suggestion", systemSymbol: .pencil, sheet: .productEditSuggestion(product: product))
        }

        RouterLink(sheet: .duplicateProduct(
          mode: profileManager.hasPermission(.canMergeProducts) ? .mergeDuplicate : .reportDuplicate,
          product: product
        ), label: {
          if profileManager.hasPermission(.canMergeProducts) {
            Label("Merge to...", systemSymbol: .docOnDoc)
          } else {
            Label("Mark as Duplicate", systemSymbol: .docOnDoc)
          }
        })

        Menu {
          if profileManager.hasPermission(.canDeleteBarcodes) {
            RouterLink("Barcodes", systemSymbol: .barcode, sheet: .barcodeManagement(product: product))
          }

          if profileManager.hasPermission(.canAddProductLogo) {
            RouterLink("Edit Logo", systemSymbol: .photo, sheet: .productLogo(product: product, onUpload: {
              await refresh()
            }))
          }

          if profileManager.hasPermission(.canDeleteProducts) {
            Button(
              "Delete",
              systemSymbol: .trashFill,
              role: .destructive,
              action: { showDeleteProductConfirmationDialog = true }
            )
            .disabled(product.isVerified)
          }
        } label: {
          Label("Admin", systemSymbol: .gear)
            .labelStyle(.iconOnly)
        }

        ReportButton(entity: .product(product))

      } label: {
        Label("Options menu", systemSymbol: .ellipsis)
          .labelStyle(.iconOnly)
      }
    }
  }

  func onEditProduct() async {
    await refresh()
    refreshCheckIns()
  }

  func loadSummary() async {
    switch await repository.product.getSummaryById(id: product.id) {
    case let .success(summary):
      self.summary = summary
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("Failed to load product summary. Error: \(error) (\(#file):\(#line))")
    }
  }

  func refresh() async {
    async let productPromise = repository.product.getById(id: product.id)
    async let summaryPromise = repository.product.getSummaryById(id: product.id)

    switch await productPromise {
    case let .success(refreshedProduct):
        await MainActor.run {
            withAnimation {
                product = refreshedProduct
            }
        }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("Failed to refresh product by id. Error: \(error) (\(#file):\(#line))")
    }

    switch await summaryPromise {
    case let .success(summary):
        await MainActor.run {
            self.summary = summary
        }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("Failed to load product summary. Error: \(error) (\(#file):\(#line))")
    }
  }

  func refreshCheckIns() {
    resetView += 1
  }

  func verifyProduct(product: Product.Joined, isVerified: Bool) async {
    switch await repository.product.verification(id: product.id, isVerified: isVerified) {
    case .success:
      feedbackManager.trigger(.notification(.success))
      await refresh()
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("Failed to verify product. Error: \(error) (\(#file):\(#line))")
    }
  }

  func deleteProduct(_ product: Product.Joined) async {
    switch await repository.product.delete(id: product.id) {
    case .success:
      feedbackManager.trigger(.notification(.success))
      router.removeLast()
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("Failed to delete product. Error: \(error) (\(#file):\(#line))")
    }
  }

  func addBarcodeToProduct(_ barcode: Barcode) async {
    switch await repository.productBarcode.addToProduct(product: product, barcode: barcode) {
    case .success:
      feedbackManager.toggle(.success("Barcode added!"))
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("adding barcode \(barcode.barcode) to product failed. Error: \(error) (\(#file):\(#line))")
    }
  }
}
