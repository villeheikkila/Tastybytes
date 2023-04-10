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
              Button(action: { viewModel.verifyProduct(product) }, label: {
                Label("Verify", systemImage: "checkmark")
              }).tint(.green)
              Button(action: { router.navigate(sheet: .editProduct(product: product, onEdit: {
                Task {
                  await viewModel.loadProducts()
                }
              })) }, label: {
                Label("Edit", systemImage: "pencil")
              }).tint(.yellow)
              Button(role: .destructive, action: { viewModel.deleteProduct = product }, label: {
                Label("Delete", systemImage: "trash")
              })
            }
        }
      }
    }
    .listStyle(.plain)
    .confirmationDialog("Delete Product Confirmation",
                        isPresented: $viewModel.showDeleteProductConfirmationDialog,
                        presenting: viewModel.deleteProduct)
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
