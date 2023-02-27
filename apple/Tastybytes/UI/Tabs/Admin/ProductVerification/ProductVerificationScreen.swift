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

        VStack {
          if let createdBy = product.createdBy {
            HStack {
              AvatarView(avatarUrl: createdBy.avatarUrl, size: 16, id: createdBy.id)
              Text(createdBy.preferredName).font(.caption).bold()
              Spacer()
              // swiftlint:disable force_try
              if let createdAt = product.createdAt, let date = try! parseDate(from: createdAt) {
                Text(date.relativeTime()).font(.caption).bold()
              }
            }
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
      }
    }
    .listStyle(.plain)
    .sheet(item: $viewModel.editProduct, content: { editProduct in
      NavigationStack {
        DismissableSheet(title: "Edit Product") {
          AddProductView(viewModel.client, mode: .edit(editProduct), onEdit: {
            viewModel.onEditProduct()
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
