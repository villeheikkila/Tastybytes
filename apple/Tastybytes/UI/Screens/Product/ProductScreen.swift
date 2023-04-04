import SwiftUI

struct ProductScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var hapticManager: HapticManager
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
      onRefresh: {
        viewModel.refresh()
      },
      header: {
        Section {
          ProductItemView(product: viewModel.product, extras: [.companyLink, .logo])
          Button(action: { viewModel.activeSheet = .checkIn }, label: {
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

        if let summary = viewModel.summary, summary.averageRating != nil {
          Section {
            SummaryView(summary: summary)
          }.listRowSeparator(.hidden)
        }
      }
    )
    .id(viewModel.resetView)
    .task {
      if viewModel.summary == nil {
        viewModel.loadSummary()
      }
    }
    .toolbar {
      toolbarContent
    }
    .sheet(item: $viewModel.activeSheet) { sheet in
      NavigationStack {
        switch sheet {
        case .checkIn:
          CheckInSheet(viewModel.client, product: viewModel.product, onCreation: { _ in
            viewModel.refreshCheckIns()
          })
        case .barcodes:
          BarcodeManagementSheet(viewModel.client, product: viewModel.product)
        case .editSuggestion:
          DismissableSheet(title: "Edit Suggestion") {
            AddProductView(viewModel.client, mode: .editSuggestion(viewModel.product))
          }
        case .editProduct:
          DismissableSheet(title: "Edit Product") {
            AddProductView(viewModel.client, mode: .edit(viewModel.product), onEdit: {
              viewModel.onEditProduct()
            })
          }
        case .duplicateProduct:
          DuplicateProductSheet(
            viewModel.client,
            mode: profileManager.hasPermission(.canMergeProducts) ? .mergeDuplicate : .reportDuplicate,
            product: viewModel.product
          )
        case .barcodeScanner:
          BarcodeScannerSheet(onComplete: { barcode in
            viewModel.addBarcodeToProduct(barcode: barcode, onComplete: {
              toastManager.toggle(.success("Barcode added"))
            })
          })
        }
      }.if(sheet == .barcodeScanner, transform: { view in view.presentationDetents([.medium]) })
    }
    .confirmationDialog("Unverify Product",
                        isPresented: $viewModel.showUnverifyProductConfirmation,
                        presenting: viewModel.product)
    { presenting in
      Button("Unverify \(presenting.name) product", role: .destructive, action: {
        hapticManager.trigger(.notification(.success))
        viewModel.verifyProduct(isVerified: false)
      })
    }
    .confirmationDialog("Delete Product Confirmation",
                        isPresented: $viewModel.showDeleteProductConfirmationDialog,
                        presenting: viewModel.product)
    { presenting in
      Button(
        "Delete \(presenting.getDisplayName(.fullName)) Product",
        role: .destructive,
        action: { viewModel.deleteProduct(onDelete: {
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
        Button(action: { viewModel.activeSheet = .checkIn }, label: {
          Label("Check-in", systemImage: "plus").bold()
        }).disabled(!profileManager.hasPermission(.canCreateCheckIns))

        ShareLink("Share", item: NavigatablePath.product(id: viewModel.product.id).url)

        if profileManager.hasPermission(.canAddBarcodes) {
          Button(action: { viewModel.activeSheet = .barcodeScanner }, label: {
            Label("Add Barcode", systemImage: "barcode.viewfinder")
          })
        }
        Divider()

        if profileManager.hasPermission(.canEditCompanies) {
          Button(action: { viewModel.activeSheet = .editProduct }, label: {
            Label("Edit", systemImage: "pencil")
          })
        } else {
          Button(action: { viewModel.activeSheet = .editSuggestion }, label: {
            Label("Edit Suggestion", systemImage: "pencil")
          })
        }

        Button(action: { viewModel.activeSheet = .duplicateProduct }, label: {
          if profileManager.hasPermission(.canMergeProducts) {
            Label("Merge to...", systemImage: "doc.on.doc")
          } else {
            Label("Mark as duplicate", systemImage: "doc.on.doc")
          }
        })

        if viewModel.product.isVerified {
          Button(action: { viewModel.showUnverifyProductConfirmation = true }, label: {
            Label("Verified", systemImage: "checkmark.circle")
          })
        } else if profileManager.hasPermission(.canVerify) {
          Button(action: { viewModel.verifyProduct(isVerified: true) }, label: {
            Label("Verify", systemImage: "checkmark")
          })
        } else {
          Label("Not verified", systemImage: "x.circle")
        }

        if profileManager.hasPermission(.canDeleteBarcodes) {
          Button(action: { viewModel.activeSheet = .barcodes }, label: {
            Label("Barcodes", systemImage: "barcode")
          })
        }

        if profileManager.hasPermission(.canDeleteProducts) {
          Button(role: .destructive, action: { viewModel.showDeleteConfirmation() }, label: {
            Label("Delete", systemImage: "trash.fill")
          }).disabled(viewModel.product.isVerified)
        }
      } label: {
        Label("Options menu", systemImage: "ellipsis")
          .labelStyle(.iconOnly)
      }
    }
  }
}
