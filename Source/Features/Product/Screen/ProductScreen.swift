import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
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

@MainActor
struct ProductInnerScreen: View {
    private let logger = Logger(category: "ProductScreen")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(ImageUploadEnvironmentModel.self) private var imageUploadEnvironmentModel
    @Environment(Router.self) private var router
    @State private var isInitialized = false
    @State private var product: Product.Joined
    @State private var summary: Summary?
    @State private var showDeleteProductConfirmationDialog = false
    @State private var showUnverifyProductConfirmation = false
    @State private var loadedWithBarcode: Barcode?
    @State private var alertError: AlertError?
    @State private var showTranslator = false
    // check-in images
    @State private var checkInImageTask: Task<Void, Never>?
    @State private var checkInImages = [ImageEntity.JoinedCheckIn]()
    @State private var isLoadingCheckInImages = false
    @State private var checkInImagesPage = 0
    // state
    @State private var sheet: Sheet?
    @State private var state: ScreenState = .loading
    // wishlist
    @State private var isOnWishlist = false
    @State private var checkInLoader: CheckInListLoader

    init(repository: Repository, product: Product.Joined, loadedWithBarcode: Barcode? = nil) {
        _checkInLoader = State(initialValue: CheckInListLoader(fetcher: { from, to, segment in
            await repository.checkIn.getByProductId(id: product.id, segment: segment, from: from, to: to)
        }, id: "ProductScreen"))
        _product = State(initialValue: product)
        _loadedWithBarcode = State(initialValue: loadedWithBarcode)
    }

    var body: some View {
        @Bindable var imageUploadEnvironmentModel = imageUploadEnvironmentModel
        List {
            if state == .populated {
                populatedContent
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
        .translateText(isPresented: $showTranslator, text: product.formatted(.fullName))
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .top, alignment: .trailing) {
            if loadedWithBarcode != nil {
                ProductScreenLoadedFromBarcodeOverlay(loadedWithBarcode: $loadedWithBarcode)
            }
        }
        .sheets(item: $sheet)
        .sensoryFeedback(.success, trigger: checkInLoader.isRefreshing) { oldValue, newValue in
            oldValue && !newValue
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
        .alertError($alertError)
    }

    @ViewBuilder
    var populatedContent: some View {
        ProductScreenHeader(
            product: product,
            summary: summary,
            checkInImages: checkInImages,
            loadMoreImages: loadMoreImages,
            onCreateCheckIn: onCreateCheckIn
        )
        .listRowSeparator(.hidden)
        CheckInListSegmentPicker(showCheckInsFrom: $checkInLoader.showCheckInsFrom)
        CheckInListContent(checkIns: $checkInLoader.checkIns, alertError: $checkInLoader.alertError, loadedFrom: .product, onCheckInUpdate: checkInLoader.onCheckInUpdate, onCreateCheckIn: checkInLoader.onCreateCheckIn, onLoadMore: {
            checkInLoader.onLoadMore()
        })
        CheckInListLoadingIndicator(isLoading: $checkInLoader.isLoading, isRefreshing: $checkInLoader.isRefreshing)
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) { HStack {} }
        ToolbarItemGroup(placement: .topBarTrailing) {
            ProgressButton("wishlist.add.label", systemImage: "star", actionOptions: []) {
                await toggleWishlist()
            }
            .symbolVariant(isOnWishlist ? .fill : .none)
            Menu {
                ControlGroup {
                    ProductShareLinkView(product: product)
                    Button("checkIn.create.label", systemImage: "plus", action: { sheet = .checkIn(.create(product: product, onCreation: checkInLoader.onCreateCheckIn)) })
                        .disabled(!profileEnvironmentModel.hasPermission(.canCreateCheckIns))
                    if profileEnvironmentModel.hasPermission(.canAddBarcodes) {
                        Button(
                            "labels.add",
                            systemImage: "barcode.viewfinder",
                            action: { sheet = .barcodeScanner(onComplete: { barcode in
                                Task { await addBarcodeToProduct(barcode) }
                            }) }
                        )
                    }
                }
                VerificationButton(isVerified: product.isVerified, verify: {
                    await verifyProduct(product: product, isVerified: true)
                }, unverify: {
                    showUnverifyProductConfirmation = true
                })
                Divider()
                RouterLink("product.screen.open", systemImage: "grid", screen: .product(product))
                RouterLink(
                    "subBrand.screen.open",
                    systemImage: "cart",
                    screen: .fetchSubBrand(product.subBrand)
                )
                RouterLink("brand.screen.open", systemImage: "cart", screen: .fetchBrand(product.subBrand.brand))
                RouterLink(
                    "company.screen.open",
                    systemImage: "network",
                    screen: .company(product.subBrand.brand.brandOwner)
                )
                Divider()
                if profileEnvironmentModel.hasPermission(.canEditCompanies) {
                    Button("labels.edit", systemImage: "pencil", action: { sheet = .productEdit(product: product, onEdit: { updatedProduct in
                        withAnimation {
                            product = updatedProduct
                            checkInLoader.onUpdateProduct(updatedProduct)
                        }
                    }) })
                } else {
                    Button(
                        "product.editSuggestion.label",
                        systemImage: "pencil",
                        action: { sheet = .productEditSuggestion(product: product) }
                    )
                }

                Button(action: { sheet = .duplicateProduct(
                    mode: profileEnvironmentModel.hasPermission(.canMergeProducts) ? .mergeDuplicate : .reportDuplicate,
                    product: product
                ) }, label: {
                    if profileEnvironmentModel.hasPermission(.canMergeProducts) {
                        Label("product.mergeTo.label", systemImage: "doc.on.doc")
                    } else {
                        Label("product.markAsDuplicate.label", systemImage: "doc.on.doc")
                    }
                })

                Menu {
                    if profileEnvironmentModel.hasPermission(.canDeleteBarcodes) {
                        Button("barcode.management.open", systemImage: "barcode", action: { sheet = .barcodeManagement(product: product) })
                    }

                    if profileEnvironmentModel.hasPermission(.canDeleteProducts) {
                        Button(
                            "labels.delete",
                            systemImage: "trash.fill",
                            role: .destructive,
                            action: { showDeleteProductConfirmationDialog = true }
                        )
                        .disabled(product.isVerified)
                    }
                } label: {
                    Label("admin.menuSection.title", systemImage: "gear")
                        .labelStyle(.iconOnly)
                }

                Button("labels.translate", systemImage: "bubble.left.and.text.bubble.right") {
                    showTranslator = true
                }
                ReportButton(entity: .product(product))
            } label: {
                Label("labels.menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
            .confirmationDialog("product.unverify.confirmation.description",
                                isPresented: $showUnverifyProductConfirmation,
                                presenting: product)
            { presenting in
                ProgressButton("product.unverify.confirmation.label \(presenting.name)", role: .destructive, action: {
                    await verifyProduct(product: presenting, isVerified: false)
                })
            }
            .confirmationDialog("product.delete.confirmation.description",
                                isPresented: $showDeleteProductConfirmationDialog,
                                titleVisibility: .visible,
                                presenting: product)
            { presenting in
                ProgressButton(
                    "product.delete.confirmation.label \(presenting.formatted(.fullName))",
                    role: .destructive,
                    action: { await deleteProduct(presenting) }
                )
            }
        }
    }

    func loadMoreImages() {
        checkInImageTask = Task {
            defer { checkInImageTask = nil }
            await fetchImages(reset: false)
        }
    }

    func onCreateCheckIn(checkIn: CheckIn) async {
        checkInLoader.onCreateCheckIn(checkIn)
        switch await repository.product.getSummaryById(id: product.id) {
        case let .success(summary):
            self.summary = summary
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to load product summary. Error: \(error) (\(#file):\(#line))")
        }
    }

    func getProductData(isRefresh: Bool = false) async {
        async let loadInitialCheckInsPromise: Void = checkInLoader.loadData(isRefresh: isRefresh)
        async let productPromise = repository.product.getById(id: product.id)
        async let summaryPromise = repository.product.getSummaryById(id: product.id)
        async let wishlistPromise = repository.product.checkIfOnWishlist(id: product.id)
        async let fetchImagePromise: Void = fetchImages(reset: true)

        let (_, productResult, summaryResult, wishlistResult, _) = await (loadInitialCheckInsPromise,
                                                                          productPromise,
                                                                          summaryPromise,
                                                                          wishlistPromise,
                                                                          fetchImagePromise)

        var errors: [Error] = []
        switch productResult {
        case let .success(refreshedProduct):
            withAnimation {
                product = refreshedProduct
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            errors.append(error)
            logger.error("Failed to refresh product by id. Error: \(error) (\(#file):\(#line))")
        }

        switch summaryResult {
        case let .success(summary):
            self.summary = summary
        case let .failure(error):
            guard !error.isCancelled else { return }
            errors.append(error)
            logger.error("Failed to load product summary. Error: \(error) (\(#file):\(#line))")
        }

        switch wishlistResult {
        case let .success(isOnWishlist):
            withAnimation {
                self.isOnWishlist = isOnWishlist
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            errors.append(error)
            logger.error("Failed to load wishlist status. Error: \(error) (\(#file):\(#line))")
        }

        withAnimation(.easeIn) {
            state = if !errors.isEmpty {
                .error(errors)
            } else {
                .populated
            }
        }
    }

    func verifyProduct(product: Product.Joined, isVerified: Bool) async {
        switch await repository.product.verification(id: product.id, isVerified: isVerified) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            self.product = product.copyWith(isVerified: isVerified)
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to verify product. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteProduct(_ product: Product.Joined) async {
        switch await repository.product.delete(id: product.id) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            router.removeLast()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete product. Error: \(error) (\(#file):\(#line))")
        }
    }

    func addBarcodeToProduct(_ barcode: Barcode) async {
        switch await repository.productBarcode.addToProduct(product: product, barcode: barcode) {
        case .success:
            feedbackEnvironmentModel.toggle(.success("bracode.add.success.toast"))
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Adding barcode \(barcode.barcode) to product failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func fetchImages(reset: Bool) async {
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

        switch await repository.checkIn.getCheckInImages(by: .product(product), from: from, to: to) {
        case let .success(checkIns):
            withAnimation {
                checkInImages.append(contentsOf: checkIns)
            }
            checkInImagesPage += 1
            isLoadingCheckInImages = false
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Fetching check-in images failed. Description: \(error.localizedDescription). Error: \(error) (\(#file):\(#line))")
        }
    }

    func toggleWishlist() async {
        if isOnWishlist {
            switch await repository.product.removeFromWishlist(productId: product.id) {
            case .success:
                feedbackEnvironmentModel.trigger(.notification(.success))
                withAnimation {
                    isOnWishlist = false
                }
            case let .failure(error):
                guard !error.isCancelled else { return }
                logger.error("Removing from wishlist failed. Error: \(error) (\(#file):\(#line))")
            }
        } else {
            switch await repository.product.addToWishlist(productId: product.id) {
            case .success:
                feedbackEnvironmentModel.trigger(.notification(.success))
                withAnimation {
                    isOnWishlist = true
                }
            case let .failure(error):
                guard !error.isCancelled else { return }
                logger.error("Adding to wishlist failed. Error: \(error) (\(#file):\(#line))")
            }
        }
    }
}
