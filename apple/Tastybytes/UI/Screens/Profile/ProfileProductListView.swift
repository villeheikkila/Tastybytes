import SwiftUI

struct ProfileProductListView: View {
  @StateObject private var viewModel: ViewModel

  init(_ client: Client, profile: Profile) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, profile: profile))
  }

  var body: some View {
    List {
      ForEach(viewModel.products, id: \.id) { product in
        ProfileProductItemView(product: product)
      }
    }
    .navigationTitle("Products")
    .task {
      await viewModel.loadProducts()
    }
  }
}

struct ProfileProductItemView: View {
  let product: Product.Joined

  var body: some View {
    VStack(alignment: .leading, spacing: 3) {
      HStack {
        Text(product.getDisplayName(.fullName))
          .font(.system(size: 16, weight: .bold, design: .default))
        Spacer()
        if let currentUserCheckIns = product.currentUserCheckIns, currentUserCheckIns > 0 {
          Image(systemName: "checkmark")
        }
      }
      if let description = product.description {
        Text(description)
          .font(.system(size: 12, weight: .medium, design: .default))
      }

      Text(product.getDisplayName(.brandOwner))
        .font(.system(size: 14, weight: .bold, design: .default))
        .foregroundColor(.secondary)

      HStack {
        CategoryNameView(category: product.category)
        ForEach(product.subcategories, id: \.id) { subcategory in
          ChipView(title: subcategory.name, cornerRadius: 5)
        }
        Spacer()
        if let averageRating = product.averageRating {
          RatingView(rating: averageRating, type: .small)
        }
      }
    }
  }
}

extension ProfileProductListView {
  @MainActor class ViewModel: ObservableObject {
    let logger = getLogger(category: "ProfileProductListView")
    let client: Client
    let profile: Profile
    @Published var products: [Product.Joined] = []

    init(_ client: Client, profile: Profile) {
      self.client = client
      self.profile = profile
    }

    func loadProducts() async {
      switch await client.product.getByProfile(id: profile.id) {
      case let .success(products):
        withAnimation {
          self.products = products
        }
      case let .failure(error):
        logger.error("error occured while loading products: \(error)")
      }
    }
  }
}
