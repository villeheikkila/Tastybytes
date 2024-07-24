import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI
import Translation

struct ProductScreen: View {
    @Environment(Repository.self) private var repository
    let product: Product.Joined
    let loadedWithBarcode: Barcode?

    init(product: Product.Joined, loadedWithBarcode: Barcode? = nil) {
        self.product = product
        self.loadedWithBarcode = loadedWithBarcode
    }

    var body: some View {
        ProductInnerScreen(repository: repository, product: product, loadedWithBarcode: loadedWithBarcode)
    }
}

struct ProductInnerScreen: View {
    private let logger = Logger(category: "ProductScreen")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(ImageUploadEnvironmentModel.self) private var imageUploadEnvironmentModel
    @Environment(Router.self) private var router
    @State private var product: Product.Joined
    @State private var summary: Summary?
    @State private var loadedWithBarcode: Barcode?
    @State private var showTranslator = false
    // check-in images
    @State private var checkInImageTask: Task<Void, Never>?
    @State private var checkInImages = [ImageEntity.JoinedCheckIn]()
    @State private var isLoadingCheckInImages = false
    @State private var checkInImagesPage = 0
    // state
    @State private var state: ScreenState = .loading
    // wishlist
    @State private var isOnWishlist = false
    @State private var checkInLoader: CheckInListLoader

    init(repository: Repository, product: Product.Joined, loadedWithBarcode: Barcode? = nil) {
        _checkInLoader = State(initialValue: CheckInListLoader(fetcher: { from, to, segment in
            try await repository.checkIn.getByProductId(id: product.id, segment: segment, from: from, to: to)
        }, id: "ProductScreen"))
        _product = State(initialValue: product)
        _loadedWithBarcode = State(initialValue: loadedWithBarcode)
    }

    var body: some View {
        @Bindable var imageUploadEnvironmentModel = imageUploadEnvironmentModel
        List {
            if state.isPopulated {
                content
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .overlay {
            ScreenStateOverlayView(state: state, errorDescription: "product.screen.failedToLoadError \(product.formatted(.fullName))", errorAction: { await getProductData()
            })
        }
        .refreshable {
            await getProductData()
        }
        .navigationTitle(product.formatted(.fullName))
        .navigationBarTitleDisplayMode(.inline)
        .translationPresentation(isPresented: $showTranslator, text: product.formatted(.fullName))
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .top, alignment: .trailing) {
            if loadedWithBarcode != nil {
                ProductScreenLoadedFromBarcodeOverlay(loadedWithBarcode: $loadedWithBarcode)
            }
        }
        .onDisappear {
            checkInImageTask?.cancel()
        }
        .initialTask {
            await getProductData()
        }
        .onChange(of: imageUploadEnvironmentModel.uploadedImageForCheckIn) { _, newValue in
            if let updatedCheckIn = newValue {
                imageUploadEnvironmentModel.uploadedImageForCheckIn = nil
                checkInLoader.onCheckInUpdate(updatedCheckIn)
            }
        }
    }

    @ViewBuilder private var content: some View {
        ProductScreenHeader(
            product: product,
            summary: summary,
            checkInImages: checkInImages,
            loadMoreImages: loadMoreImages,
            onCreateCheckIn: onCreateCheckIn
        )
        .listRowSeparator(.hidden)
        CheckInListSegmentPickerView(showCheckInsFrom: $checkInLoader.showCheckInsFrom)
        CheckInListContentView(checkIns: $checkInLoader.checkIns, onCheckInUpdate: checkInLoader.onCheckInUpdate, onCreateCheckIn: checkInLoader.onCreateCheckIn, onLoadMore: checkInLoader.onLoadMore)
            .checkInCardLoadedFrom(.product)
        CheckInListLoadingIndicatorView(isLoading: $checkInLoader.isLoading, isRefreshing: $checkInLoader.isRefreshing)
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) { HStack {} }
        ToolbarItemGroup(placement: .topBarTrailing) {
            AsyncButton("wishlist.add.label", systemImage: "star") {
                await toggleWishlist()
            }
            .asyncButtonLoadingStyle(.plain)
            .symbolVariant(isOnWishlist ? .fill : .none)
            Menu {
                ControlGroup {
                    ProductShareLinkView(product: product)
                    RouterLink("checkIn.create.label", systemImage: "plus", open: .sheet(.checkIn(.create(product: product, onCreation: checkInLoader.onCreateCheckIn))))
                        .disabled(!profileEnvironmentModel.hasPermission(.canCreateCheckIns))
                    if profileEnvironmentModel.hasPermission(.canAddBarcodes) {
                        RouterLink(
                            "labels.add",
                            systemImage: "barcode.viewfinder",
                            open: .sheet(.barcodeScanner(onComplete: { barcode in
                                await addBarcodeToProduct(barcode)
                            }))
                        )
                    }
                }
                Divider()
                RouterLink(
                    "subBrand.screen.open",
                    systemImage: "cart",
                    open: .screen(.subBrand(product.subBrand))
                )
                RouterLink("brand.screen.open", systemImage: "cart", open: .screen(.fetchBrand(product.subBrand.brand)))
                RouterLink(
                    "company.screen.open",
                    systemImage: "network",
                    open: .screen(.company(product.subBrand.brand.brandOwner))
                )
                Divider()

                Button("labels.translate", systemImage: "bubble.left.and.text.bubble.right") {
                    showTranslator = true
                }

                Divider()
                RouterLink(
                    "product.editSuggestion.label",
                    systemImage: "pencil",
                    open: .sheet(.product(.editSuggestion(product)))
                )
                ReportButton(entity: .product(product))
                Divider()
                AdminRouterLink(open: .sheet(.productAdmin(id: product.id, onUpdate: { _ in
                    await getProductData()
                }, onDelete: { _ in
                    router.removeLast()
                })))
            } label: {
                Label("labels.menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
        }
    }

    func loadMoreImages() {
        checkInImageTask = Task {
            defer { checkInImageTask = nil }
            await fetchImages(reset: false)
        }
    }

    private func onCreateCheckIn(checkIn: CheckIn) async {
        checkInLoader.onCreateCheckIn(checkIn)
        do {
            let summary = try await repository.product.getSummaryById(id: product.id)
            self.summary = summary
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to load product summary. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func getProductData(isRefresh: Bool = false) async {
        async let loadInitialCheckInsPromise: Void = checkInLoader.loadData(isRefresh: isRefresh)
        async let productPromise = repository.product.getById(id: product.id)
        async let summaryPromise = repository.product.getSummaryById(id: product.id)
        async let wishlistPromise = repository.product.checkIfOnWishlist(id: product.id)
        async let fetchImagePromise: Void = fetchImages(reset: true)
        var errors: [Error] = []
        do {
            let (_, productResult, summaryResult, wishlistResult, _) = try await (loadInitialCheckInsPromise,
                                                                                  productPromise,
                                                                                  summaryPromise,
                                                                                  wishlistPromise,
                                                                                  fetchImagePromise)
            withAnimation {
                product = productResult
                summary = summaryResult
                isOnWishlist = wishlistResult
            }
        } catch {
            guard !error.isCancelled else { return }
            errors.append(error)
            logger.error("Failed to load product summary. Error: \(error) (\(#file):\(#line))")
        }

        state = .getState(errors: errors, withHaptics: isRefresh, feedbackEnvironmentModel: feedbackEnvironmentModel)
    }

    private func addBarcodeToProduct(_ barcode: Barcode) async {
        do {
            try await repository.productBarcode.addToProduct(product: product, barcode: barcode)
            router.open(.toast(.success("barcode.add.success.toast")))
        } catch {
            guard !error.isCancelled else { return }
            guard !error.isDuplicate else {
                router.open(.toast(.warning("barcode.duplicate.toast")))
                return
            }
            router.open(.alert(.init(title: "barcode.error.failedToAdd.title", retryLabel: "labels.retry", retry: {
                Task { await addBarcodeToProduct(barcode) }
            })))
            logger.error("Adding barcode \(barcode.barcode) to product failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func fetchImages(reset: Bool) async {
        if reset {
            withAnimation {
                checkInImageTask?.cancel()
                checkInImages = []
                isLoadingCheckInImages = false
                checkInImagesPage = 0
            }
        }
        guard !isLoadingCheckInImages else { return }
        let (from, to) = getPagination(page: checkInImagesPage, size: 10)
        isLoadingCheckInImages = true

        do {
            let checkIns = try await repository.checkIn.getCheckInImages(by: .product(product), from: from, to: to)
            withAnimation {
                checkInImages.append(contentsOf: checkIns)
            }
            checkInImagesPage += 1
            isLoadingCheckInImages = false
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Fetching check-in images failed. Description: \(error.localizedDescription). Error: \(error) (\(#file):\(#line))")
        }
    }

    private func toggleWishlist() async {
        if isOnWishlist {
            do {
                try await repository.product.removeFromWishlist(productId: product.id)
                feedbackEnvironmentModel.trigger(.notification(.success))
                withAnimation {
                    isOnWishlist = false
                }
            } catch {
                guard !error.isCancelled else { return }
                logger.error("Removing from wishlist failed. Error: \(error) (\(#file):\(#line))")
            }
        } else {
            do { try await repository.product.addToWishlist(productId: product.id)
                feedbackEnvironmentModel.trigger(.notification(.success))
                withAnimation {
                    isOnWishlist = true
                }
            } catch {
                guard !error.isCancelled else { return }
                logger.error("Adding to wishlist failed. Error: \(error) (\(#file):\(#line))")
            }
        }
    }
}
