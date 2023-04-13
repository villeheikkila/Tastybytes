import SwiftUI

struct DuplicateProductScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var hapticManager: HapticManager

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    List {
      ForEach(viewModel.products) { product in

        VStack {
          if let createdBy = product.createdBy {
            HStack {
              AvatarView(avatarUrl: createdBy.avatarUrl, size: 16, id: createdBy.id)
              Text(createdBy.preferredName).font(.caption).bold()
              Spacer()
              if let createdAt = product.createdAt, let date = Date(timestamptzString: createdAt) {
                Text(date.customFormat(.relativeTime)).font(.caption).bold()
              }
            }
          }
          ProductItemView(product: product)
            .contentShape(Rectangle())
            .accessibilityAddTraits(.isLink)
            .onTapGesture {
              router.navigate(screen: .product(product))
            }
            .swipeActions {
              ProgressButton("Verify", systemImage: "checkmark", action: { await viewModel.verifyProduct(product) }).tint(.green)
              RouterLink("Edit", systemImage: "pencil", sheet: .editProduct(product: product, onEdit: {
                Task {
                  await viewModel.loadProducts()
                }
              })).tint(.yellow)
              Button(role: .destructive, action: { viewModel.deleteProduct = product }, label: {
                Label("Delete", systemImage: "trash")
              })
            }
        }
      }
    }
    .listStyle(.plain)
    .confirmationDialog("Are you sure you want to delete the product and all of its check-ins?",
                        isPresented: $viewModel.showDeleteProductConfirmationDialog,
                        titleVisibility: .visible,
                        presenting: viewModel.deleteProduct)
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
    .navigationBarTitle("Unverified Products")
    .refreshable {
      await hapticManager.wrapWithHaptics {
        await viewModel.loadProducts()
      }
    }
    .task {
      await viewModel.loadProducts()
    }
  }
}
