import SwiftUI

struct ProductVerificationScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var hapticManager: HapticManager

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    List {
      ForEach(viewModel.products, id: \.id) { product in
        ProductItemView(product: product)
          .contentShape(Rectangle())
          .accessibilityAddTraits(.isLink)
          .onTapGesture {
            router.navigate(to: .product(product), resetStack: false)
          }
          .swipeActions {
            Button(action: { viewModel.verifyProduct(product) }, label: {
              Label("Verify", systemImage: "checkmark")
            }).tint(.green)
            Button(action: { viewModel.editProduct = product }, label: {
              Label("Edit", systemImage: "pencil")
            }).tint(.yellow)
            Button(role: .destructive, action: { viewModel.deleteProduct = product }, label: {
              Label("Delete", systemImage: "trash")
            })
          }
      }
    }
    .listStyle(.plain)
    .sheet(item: $viewModel.editProduct, content: { editProduct in
      NavigationStack {
        DismissableSheet(title: "Edit Product") {
          AddProductView(viewModel.client, mode: .edit(editProduct), onEdit: {
            Task {
              await viewModel.loadProducts()
            }
          })
        }
      }
    })
    .confirmationDialog("Delete Product Confirmation",
                        isPresented: $viewModel.showDeleteProductConfirmationDialog,
                        presenting: viewModel.deleteProduct) { presenting in
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
    .navigationBarTitle("Unverified Products")
    .refreshable {
      await viewModel.loadProducts()
    }
    .task {
      await viewModel.loadProducts()
    }
  }
}
