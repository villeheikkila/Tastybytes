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
        await viewModel.refresh()
      },
      header: {
        Section {
          ProductItemView(product: viewModel.product, extras: [.companyLink, .logo])
          RouterLink(sheet: .newCheckIn(viewModel.product, onCreation: { _ in
            Task { await viewModel.refreshCheckIns() }
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
        await viewModel.loadSummary()
      }
    }
    .toolbar {
      toolbarContent
    }
    .confirmationDialog("Unverify Product",
                        isPresented: $viewModel.showUnverifyProductConfirmation,
                        presenting: viewModel.product)
    { presenting in
      ProgressButton("Unverify \(presenting.name) product", role: .destructive, action: {
        await viewModel.verifyProduct(isVerified: false)
        hapticManager.trigger(.notification(.success))
      })
    }
    .confirmationDialog("Are you sure you want to delete the product and all of its check-ins?",
                        isPresented: $viewModel.showDeleteProductConfirmationDialog,
                        titleVisibility: .visible,
                        presenting: viewModel.product)
    { presenting in
      ProgressButton(
        "Delete \(presenting.getDisplayName(.fullName))",
        role: .destructive,
        action: { await viewModel.deleteProduct(onDelete: {
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
        RouterLink(sheet: .newCheckIn(viewModel.product, onCreation: { _ in
          Task { await viewModel.refreshCheckIns() }
        }), label: {
          Label("Check-in", systemImage: "plus").bold()
        }).disabled(!profileManager.hasPermission(.canCreateCheckIns))

        ShareLink("Share", item: NavigatablePath.product(id: viewModel.product.id).url)

        if profileManager.hasPermission(.canAddBarcodes) {
          RouterLink(sheet: .barcodeScanner(onComplete: { _ in
            toastManager.toggle(.success("Barcode added"))
          }), label: {
            Label("Add Barcode", systemImage: "barcode.viewfinder")
          })
        }
        Divider()

        if profileManager.hasPermission(.canEditCompanies) {
          RouterLink(sheet: .editProduct(product: viewModel.product), label: {
            Label("Edit", systemImage: "pencil")
          })
        } else {
          RouterLink(sheet: .productEditSuggestion(product: viewModel.product), label: {
            Label("Edit Suggestion", systemImage: "pencil")
          })
        }

        RouterLink(sheet: .duplicateProduct(
          mode: profileManager.hasPermission(.canMergeProducts) ? .mergeDuplicate : .reportDuplicate,
          product: viewModel.product
        ), label: {
          if profileManager.hasPermission(.canMergeProducts) {
            Label("Merge to...", systemImage: "doc.on.doc")
          } else {
            Label("Mark as duplicate", systemImage: "doc.on.doc")
          }
        })

        VerificationButton(isVerified: viewModel.product.isVerified, verify: {
          await viewModel.verifyProduct(isVerified: true)
        }, unverify: {
          viewModel.showUnverifyProductConfirmation = true
        })

        if profileManager.hasPermission(.canDeleteBarcodes) {
          RouterLink(sheet: .barcodeManagement(product: viewModel.product), label: {
            Label("Barcodes", systemImage: "barcode")
          })
        }

        ReportButton(entity: .product(viewModel.product))

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
