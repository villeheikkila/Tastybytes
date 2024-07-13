import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ProductFeedScreen: View {
    private let logger = Logger(category: "ProductFeedView")
    @Environment(Repository.self) private var repository
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @State private var products = [Product.Joined]()
    @State private var categoryFilter: Models.Category.JoinedSubcategoriesServingStyles?
    @State private var page = 0
    @State private var isLoading = false
    @State private var isRefreshing = false
    @State private var state: ScreenState = .loading
    @State private var loadingAdditionalItemsTask: Task<Void, Never>?

    let feed: Product.FeedType

    private let pageSize = 10

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
                RouterLink(open: .screen(.product(product))) {
                    ProductEntityView(product: product, extras: [.checkInCheck, .rating])
                }
                .onAppear {
                    if product == products.last, isLoading != true {
                        loadingAdditionalItemsTask = Task {
                            defer { loadingAdditionalItemsTask = nil }
                            await loadFeedItems()
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
        .overlay {
            ScreenStateOverlayView(state: state, errorDescription: "") {
                await loadFeedItems(refresh: true)
            }
        }
        .refreshable {
            await loadFeedItems(refresh: true)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task(id: categoryFilter) {
            await loadFeedItems(refresh: true)
        }
        .onDisappear {
            loadingAdditionalItemsTask?.cancel()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarTitleMenu {
            Button(feed.label, action: { categoryFilter = nil })
            ForEach(appEnvironmentModel.categories) { category in
                Button(category.name, action: { categoryFilter = category })
            }
        }
    }

    func loadFeedItems(refresh: Bool = false) async {
        guard isLoading == false else { return }
        if refresh {
            loadingAdditionalItemsTask?.cancel()
            page = 0
            isRefreshing = true
        }
        let (from, to) = getPagination(page: page, size: pageSize)
        isLoading = true
        do { let additionalProducts = try await repository.product.getFeed(feed, from: from, to: to, categoryFilterId: categoryFilter?.id)
            guard !Task.isCancelled else { return }
            withAnimation {
                if refresh {
                    products = additionalProducts
                } else {
                    products.append(contentsOf: additionalProducts)
                }
            }
            page += 1
            state = .populated
        } catch {
            guard !error.isCancelled else { return }
            if refresh || state != .populated {
                state = .error([error])
            }
            logger.error("Fetching products failed. Error: \(error) (\(#file):\(#line))")
        }
        isLoading = false
        if refresh {
            isRefreshing = false
        }
    }
}
