
import Extensions
import Models
import Logging
import Repositories
import SwiftUI

struct ProductFeedScreen: View {
    private let logger = Logger(label: "ProductFeedView")
    @Environment(Repository.self) private var repository
    @Environment(AppModel.self) private var appModel
    @State private var products = [Product.Joined]()
    @State private var categoryFilter: Models.Category.JoinedSubcategoriesServingStyles?
    @State private var page = 0
    @State private var isLoading = false
    @State private var isRefreshing = false
    @State private var state: ScreenState = .loading
    @State private var loadingAdditionalItemsTask: Task<Void, Never>?

    let feed: Product.FeedType

    var title: LocalizedStringKey {
        if let categoryFilter {
            .init(stringLiteral: "\(feed.label): \(categoryFilter.name)")
        } else {
            feed.label
        }
    }

    var body: some View {
        List {
            ForEach(products) { product in
                RouterLink(open: .screen(.product(product.id))) {
                    ProductView(product: product)
                }
                .onAppear {
                    if product == products.last, isLoading != true {
                        loadingAdditionalItemsTask = Task {
                            defer { loadingAdditionalItemsTask = nil }
                            await loadFeedItems(page: page)
                        }
                    }
                }
            }
            if isLoading, !isRefreshing {
                ProgressView()
                    .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .animation(.default, value: products)
        .overlay {
            ScreenStateOverlayView(state: state) {
                await loadFeedItems(page: 0, refresh: true)
            }
        }
        .refreshable {
            await loadFeedItems(page: 0, refresh: true)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task(id: categoryFilter) {
            await loadFeedItems(page: 0, refresh: true)
        }
        .onDisappear {
            loadingAdditionalItemsTask?.cancel()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarTitleMenu {
            Button(feed.label, action: { categoryFilter = nil })
            ForEach(appModel.categories) { category in
                Button(category.name, action: { categoryFilter = category })
            }
        }
    }

    private func loadFeedItems(page: Int, refresh: Bool = false) async {
        guard isLoading == false else { return }
        if refresh {
            loadingAdditionalItemsTask?.cancel()
            isRefreshing = true
        }
        isLoading = true
        do {
            let additionalProducts = try await repository.product.getFeed(feed, page: page, pageSize: appModel.rateControl.productFeedPageSize, categoryFilterId: categoryFilter?.id)
            guard !Task.isCancelled else { return }
            if refresh {
                products = additionalProducts
            } else {
                products.append(contentsOf: additionalProducts)
            }
            self.page += 1
            state = .populated
        } catch {
            guard !error.isCancelled else { return }
            if refresh || state != .populated {
                state = .error(error)
            }
            logger.error("Fetching products failed. Error: \(error) (\(#file):\(#line))")
        }
        isLoading = false
        if refresh {
            isRefreshing = false
        }
    }
}
