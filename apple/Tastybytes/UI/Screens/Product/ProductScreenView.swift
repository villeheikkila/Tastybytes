import SwiftUI

struct ProductScreenView: View {
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
          ProductItemView(product: viewModel.product, extras: [.companyLink])
          Button(action: { viewModel.activeSheet = .checkIn }, label: {
            Label("Check-in!", systemImage: "plus")
              .foregroundColor(.primary)
              .fontWeight(.medium)
          })
        }.listRowSeparator(.visible)

        if let summary = viewModel.summary, summary.averageRating != nil {
          Section {
            SummaryView(summary: summary)
          }.listRowSeparator(.visible)
        }
      }
    )
    .id(viewModel.resetView)
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
          CheckInSheetView(viewModel.client, product: viewModel.product, onCreation: { _ in
            viewModel.refreshCheckIns()
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
          BarcodeScannerSheetView(onComplete: { barcode in
            viewModel.addBarcodeToProduct(barcode: barcode, onComplete: {
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
        hapticManager.trigger(of: .notification(.success))
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
          hapticManager.trigger(of: .notification(.success))
          router.removeLast()
        })
        }
      )
    }
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Menu {
        Button(action: { viewModel.setActiveSheet(.checkIn) }, label: {
          Label("Check-in", systemImage: "plus").bold()
        }).disabled(!profileManager.hasPermission(.canCreateCheckIns))

        ShareLink("Share", item: NavigatablePath.product(id: viewModel.product.id).url)

        if profileManager.hasPermission(.canAddBarcodes) {
          Button(action: { viewModel.setActiveSheet(.barcodeScanner) }, label: {
            Label("Add Barcode", systemImage: "barcode.viewfinder")
          })
        }
        Divider()

        if profileManager.hasPermission(.canEditCompanies) {
          Button(action: { viewModel.setActiveSheet(.editProduct) }, label: {
            Label("Edit", systemImage: "pencil")
          })
        } else {
          Button(action: { viewModel.setActiveSheet(.editSuggestion) }, label: {
            Label("Edit Suggestion", systemImage: "pencil")
          })
        }

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
          Button(action: { viewModel.setActiveSheet(.barcodes) }, label: {
            Label("Barcodes", systemImage: "barcode")
          })
        }

        if profileManager.hasPermission(.canDeleteProducts) {
          Button(role: .destructive, action: { viewModel.showDeleteConfirmation() }, label: {
            Label("Delete", systemImage: "trash.fill")
          }).disabled(viewModel.product.isVerified)
        }
      } label: {
        Image(systemName: "ellipsis")
      }
    }
  }
}
