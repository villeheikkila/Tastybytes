import SwiftUI

struct ProductScreen: View {
  private let logger = getLogger(category: "ProductScreen")
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var router: Router
  @State private var scrollToTop: Int = 0
  @State private var product: Product.Joined
  @State private var summary: Summary?
  @State private var showDeleteProductConfirmationDialog = false
  @State private var showUnverifyProductConfirmation = false
  @State private var resetView: Int = 0
  @Environment(\.dismiss) private var dismiss

  let client: Client

  init(_ client: Client, product: Product.Joined) {
    self.client = client
    _product = State(wrappedValue: product)
  }

  func showDeleteConfirmation() {
    showDeleteProductConfirmationDialog.toggle()
  }

  func onEditProduct() async {
    await refresh()
    await refreshCheckIns()
  }

  func loadSummary() async {
    switch await client.product.getSummaryById(id: product.id) {
    case let .success(summary):
      self.summary = summary
    case let .failure(error):
      logger.error("failed to load product summary: \(error.localizedDescription)")
    }
  }

  func refresh() async {
    async let productPromise = client.product.getById(id: product.id)
    async let summaryPromise = client.product.getSummaryById(id: product.id)

    switch await productPromise {
    case let .success(refreshedProduct):
      withAnimation {
        product = refreshedProduct
      }
    case let .failure(error):
      logger.error("failed to refresh product by id: \(error.localizedDescription)")
    }

    switch await summaryPromise {
    case let .success(summary):
      self.summary = summary
    case let .failure(error):
      logger.error("failed to load product summary: \(error.localizedDescription)")
    }
  }

  func addBarcodeToProduct(barcode: Barcode, onComplete: @escaping () -> Void) async {
    switch await client.productBarcode.addToProduct(product: product, barcode: barcode) {
    case .success:
      onComplete()
    case let .failure(error):
      logger.error("adding barcode \(barcode.barcode) failed: \(error.localizedDescription)")
    }
  }

  func refreshCheckIns() async {
    await refresh()
    resetView += 1
  }

  func verifyProduct(isVerified: Bool) async {
    switch await client.product.verification(id: product.id, isVerified: isVerified) {
    case .success:
      await refresh()
    case let .failure(error):
      logger.error("failed to verify product: \(error.localizedDescription)")
    }
  }

  func deleteProduct(onDelete: @escaping () -> Void) async {
    switch await client.product.delete(id: product.id) {
    case .success:
      onDelete()
    case let .failure(error):
      logger.error("failed to delete product: \(error.localizedDescription)")
    }
  }

  var body: some View {
    CheckInListView(
      client,
      fetcher: .product(product),
      scrollToTop: $scrollToTop,
      onRefresh: {
        await refresh()
      },
      header: {
        Section {
          ProductItemView(product: product, extras: [.companyLink, .logo])
          RouterLink(sheet: .newCheckIn(product, onCreation: { _ in
            await refreshCheckIns()
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
        await verifyProduct(isVerified: false)
        hapticManager.trigger(.notification(.success))
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
        action: { await deleteProduct(onDelete: {
          hapticManager.trigger(.notification(.success))
          router.removeLast()
        })
        }
      )
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Menu {
        VerificationButton(isVerified: product.isVerified, verify: {
          await verifyProduct(isVerified: true)
        }, unverify: {
          showUnverifyProductConfirmation = true
        })
        Divider()

        RouterLink("Check-in", systemImage: "plus", sheet: .newCheckIn(product, onCreation: { _ in
          await refreshCheckIns()
        }))
        .bold()
        .disabled(!profileManager.hasPermission(.canCreateCheckIns))

        ShareLink("Share", item: NavigatablePath.product(id: product.id).url)

        if profileManager.hasPermission(.canAddBarcodes) {
          RouterLink("Add Barcode", systemImage: "barcode.viewfinder", sheet: .barcodeScanner(onComplete: { _ in
            toastManager.toggle(.success("Barcode added"))
          }))
        }

        if profileManager.hasPermission(.canEditCompanies) {
          RouterLink("Edit", systemImage: "pencil", sheet: .editProduct(product: product))
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
            Label("Mark as duplicate", systemImage: "doc.on.doc")
          }
        })

        if profileManager.hasPermission(.canDeleteBarcodes) {
          RouterLink("Barcodes", systemImage: "barcode", sheet: .barcodeManagement(product: product))
        }

        ReportButton(entity: .product(product))

        if profileManager.hasPermission(.canDeleteProducts) {
          Button("Delete", systemImage: "trash.fill", role: .destructive, action: { showDeleteConfirmation() })
            .disabled(product.isVerified)
        }

      } label: {
        Label("Options menu", systemImage: "ellipsis")
          .labelStyle(.iconOnly)
      }
    }
  }
}
