import SwiftUI
import OSLog

struct ProductFeedScreen: View {
  private let logger = Logger(category: "ProductFeedView")
  @Environment(Repository.self) private var repository
  @Environment(FeedbackManager.self) private var feedbackManager
  @Environment(Router.self) private var router
  @Environment(AppDataManager.self) private var appDataManager
  @State private var products = [Product.Joined]()
  @State private var categoryFilter: Category.JoinedSubcategoriesServingStyles? {
    didSet {
      Task { await refresh() }
    }
  }

  @State private var page = 0
  @State private var isLoading = false

  let feed: Product.FeedType

  private let pageSize = 10

  var filteredProducts: [Product.Joined] {
    products.unique(selector: { $0.id == $1.id })
  }

  var title: String {
    if let categoryFilter {
      return "\(feed.label): \(categoryFilter.name)"
    } else {
      return feed.label
    }
  }

  var body: some View {
    List {
      ForEach(filteredProducts) { product in
        ProductItemView(product: product, extras: [.checkInCheck, .rating])
          .contentShape(Rectangle())
          .accessibilityAddTraits(.isLink)
          .onTapGesture {
            router.navigate(screen: .product(product))
          }
          .onAppear {
            if product == products.last, isLoading != true {
              Task { await fetchProductFeedItems() }
            }
          }
      }
      if isLoading {
        ProgressView()
          .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
          .listRowSeparator(.hidden)
      }
    }
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    #if !targetEnvironment(macCatalyst)
      .refreshable {
        await feedbackManager.wrapWithHaptics {
          await refresh()
        }
      }
    #endif
      .navigationTitle(title)
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbar {
        toolbarContent
      }
      .task {
        if products.isEmpty {
          await refresh()
        }
      }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarTitleMenu {
      Button(feed.label, action: { categoryFilter = nil })
      ForEach(appDataManager.categories) { category in
        Button(category.name, action: { categoryFilter = category })
      }
    }
  }

  func refresh() async {
    page = 0
    products = [Product.Joined]()
    await fetchProductFeedItems()
  }

  func getPagination(page: Int, size: Int) -> (Int, Int) {
    let limit = size + 1
    let from = page * limit
    let to = from + size
    return (from, to)
  }

  func fetchProductFeedItems(onComplete: (() -> Void)? = nil) async {
    let (from, to) = getPagination(page: page, size: pageSize)

    isLoading = true

    switch await repository.product.getFeed(feed, from: from, to: to, categoryFilterId: categoryFilter?.id) {
    case let .success(additionalProducts):
        await MainActor.run {
            withAnimation {
                products.append(contentsOf: additionalProducts)
            }
        }
      page += 1
      isLoading = false
      if let onComplete {
        onComplete()
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("fetching check-ins failed: \(error.localizedDescription)")
    }
  }
}
