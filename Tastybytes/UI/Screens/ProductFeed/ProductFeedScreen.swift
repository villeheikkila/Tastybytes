import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct ProductFeedScreen: View {
    private let logger = Logger(category: "ProductFeedView")
    @Environment(\.repository) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(Router.self) private var router
    @Environment(AppDataEnvironmentModel.self) private var appDataEnvironmentModel
    @State private var products = [Product.Joined]()
    @State private var categoryFilter: Models.Category.JoinedSubcategoriesServingStyles? {
        didSet {
            Task { await refresh() }
        }
    }

    @State private var page = 0
    @State private var isLoading = false
    @State private var isRefreshing = false

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
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        #if !targetEnvironment(macCatalyst)
            .refreshable {
                await feedbackEnvironmentModel.wrapWithHaptics {
                    await refresh()
                }
            }
        #endif
            .overlay {
                    if isLoading && !isRefreshing {
                        ProgressView()
                    }
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    toolbarContent
                }
                .task {
                    if products.isEmpty {
                        await fetchProductFeedItems()
                    }
                }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarTitleMenu {
            Button(feed.label, action: { categoryFilter = nil })
            ForEach(appDataEnvironmentModel.categories) { category in
                Button(category.name, action: { categoryFilter = category })
            }
        }
    }

    func refresh() async {
        page = 0
        products = [Product.Joined]()
        isRefreshing = true
        await fetchProductFeedItems()
        isRefreshing = false
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
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("fetching products failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
