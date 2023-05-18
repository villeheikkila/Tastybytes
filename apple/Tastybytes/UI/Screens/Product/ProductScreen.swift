import SwiftUI

struct ProductScreen: View {
  private let logger = getLogger(category: "ProductScreen")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var router: Router
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
          RouterLink(sheet: .newCheckIn(product, onCreation: { _ in
            refreshCheckIns()
          }), label: {
            HStack {
              Group {
                Image(systemName: "plus.app")
                Text("Check-in!")
              }
              .foregroundStyle(Color.accentColor)
              .fontWeight(.medium)
            }
          })
        }.listRowSeparator(.hidden)

        if let summary, summary.averageRating != nil {
          Section {
            SummaryView(summary: summary)
          }.listRowSeparator(.hidden)
        }
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

        RouterLink("Check-in", systemImage: "plus", sheet: .newCheckIn(product, onCreation: { _ in
          refreshCheckIns()
        }))
        .bold()
        .disabled(!profileManager.hasPermission(.canCreateCheckIns))

        ShareLink("Share", item: NavigatablePath.product(id: product.id).url)

        if profileManager.hasPermission(.canAddBarcodes) {
          RouterLink("Add Barcode", systemImage: "barcode.viewfinder", sheet: .barcodeScanner(onComplete: { barcode in
            Task { await addBarcodeToProduct(barcode) }
          }))
        }

        Divider()

        if profileManager.hasPermission(.canEditCompanies) {
          RouterLink("Edit", systemImage: "pencil", sheet: .productEdit(product: product))
        } else {
          RouterLink("Edit Suggestion", systemImage: "pencil", sheet: .productEditSuggestion(product: product))
        }

        RouterLink(sheet: .duplicateProduct(
          mode: profileManager.hasPermission(.canMergeProducts) ? .mergeDuplicate : .reportDuplicate,
          product: product
        ), label: {
          if profileManager.hasPermission(.canMergeProducts) {
            Label("Merge to...", systemImage: "doc.on.doc")
          } else {
            Label("Mark as Duplicate", systemImage: "doc.on.doc")
          }
        })

        Menu {
          if profileManager.hasPermission(.canDeleteBarcodes) {
            RouterLink("Barcodes", systemImage: "barcode", sheet: .barcodeManagement(product: product))
          }

          if profileManager.hasPermission(.canAddProductLogo) {
            RouterLink("Edit Logo", systemImage: "photo", sheet: .productLogo(product: product, onUpload: {
              await refresh()
            }))
          }

          if profileManager.hasPermission(.canDeleteProducts) {
            Button(
              "Delete",
              systemImage: "trash.fill",
              role: .destructive,
              action: { showDeleteProductConfirmationDialog = true }
            )
            .disabled(product.isVerified)
          }
        } label: {
          Label("Admin", systemImage: "gear")
            .labelStyle(.iconOnly)
        }

        ReportButton(entity: .product(product))

      } label: {
        Label("Options menu", systemImage: "ellipsis")
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
      logger.error("failed to load product summary: \(error.localizedDescription)")
    }
  }

  func refresh() async {
    async let productPromise = repository.product.getById(id: product.id)
    async let summaryPromise = repository.product.getSummaryById(id: product.id)

    switch await productPromise {
    case let .success(refreshedProduct):
      withAnimation {
        product = refreshedProduct
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to refresh product by id: \(error.localizedDescription)")
    }

    switch await summaryPromise {
    case let .success(summary):
      self.summary = summary
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to load product summary: \(error.localizedDescription)")
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
      logger.error("failed to verify product: \(error.localizedDescription)")
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
      logger.error("failed to delete product: \(error.localizedDescription)")
    }
  }

  func addBarcodeToProduct(_ barcode: Barcode) async {
    switch await repository.productBarcode.addToProduct(product: product, barcode: barcode) {
    case .success:
      feedbackManager.toggle(.success("Barcode added!"))
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("adding barcode \(barcode.barcode) to product failed: \(error.localizedDescription)")
    }
  }
}
