import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct ProductFeedScreen: View {
    private let logger = Logger(category: "ProductFeedView")
    @Environment(\.repository) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(Router.self) private var router
    @Environment(AppDataEnvironmentModel.self) private var appDataEnvironmentModel
    @State private var products = [Product.Joined]()
    @State private var categoryFilter: Models.Category.JoinedSubcategoriesServingStyles?
    @State private var page = 0
    @State private var isLoading = false
    @State private var isRefreshing = false
    @State private var alertError: AlertError?
    @State private var loadingAdditionalItemsTask: Task<Void, Never>?

    let feed: Product.FeedType

    private let pageSize = 10

    var filteredProducts: [Product.Joined] {
        products.unique(selector: { $0.id == $1.id })
    }

    var title: String {
        if let categoryFilter {
            "\(feed.label): \(categoryFilter.name)"
        } else {
            feed.label
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
                            loadingAdditionalItemsTask = Task {
                                defer { loadingAdditionalItemsTask = nil }
                                await fetchProductFeedItems()
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
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .task(id: categoryFilter) {
            await refresh()
        }
        .onDisappear {
            loadingAdditionalItemsTask?.cancel()
        }
        #if !targetEnvironment(macCatalyst)
        .refreshable {
            await refresh()
        }
        #endif
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            toolbarContent
        }
        .alertError($alertError)
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
        loadingAdditionalItemsTask?.cancel()
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
            withAnimation {
                products.append(contentsOf: additionalProducts)
            }
            page += 1
            isLoading = false
            if let onComplete {
                onComplete()
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("fetching products failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
