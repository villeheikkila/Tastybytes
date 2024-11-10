import Components

import Extensions
import Logging
import Models
import Repositories
import SwiftUI
import Translation

struct ProductScreen: View {
    private let logger = Logger(label: "ProductScreen")
    @Environment(Repository.self) private var repository
    @Environment(ProfileModel.self) private var profileModel
    @Environment(FeedbackModel.self) private var feedbackModel
    @Environment(CheckInModel.self) private var checkInModel
    @Environment(AppModel.self) private var appModel
    @Environment(Router.self) private var router
    @State private var product = Product.Joined()
    @State private var checkIns = [CheckIn.Joined]()
    @State private var summary: Summary?
    @State private var loadedWithBarcode: Barcode?
    @State private var showTranslator = false
    // check-in images
    @State private var checkInImages = [ImageEntity.CheckInId]()
    @State private var checkInImagesPage = 0
    // state
    @State private var state: ScreenState = .loading
    // wishlist
    @State private var isOnWishlist = false
    @State private var isRefreshing = false
    @State private var isLoading = false
    @State private var page = 0
    @State private var onSegmentChangeTask: Task<Void, Error>?
    @State private var showCheckInsFrom: CheckIn.Segment = .everyone {
        didSet {
            onSegmentChangeTask?.cancel()
            onSegmentChangeTask = Task {
                await fetchCheckIns(reset: true, segment: showCheckInsFrom)
            }
        }
    }

    private let id: Product.Id

    init(id: Product.Id, loadedWithBarcode: Barcode? = nil) {
        _loadedWithBarcode = State(initialValue: loadedWithBarcode)
        self.id = id
    }

    var body: some View {
        @Bindable var checkInModel = checkInModel
        List {
            if state.isPopulated {
                content
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .animation(.default, value: checkIns)
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
        .initialTask {
            await getProductData()
        }
    }

    @ViewBuilder private var content: some View {
        Group {
            ProductView(product: product)
                .productLogoShowPlacerholder(false)
                .productCompanyLinkEnabled(true)
                .productLogoLocation(.right)
            CreateCheckInButtonView(product: product, onCreateCheckIn: onCreateCheckIn)
            if let summary, !summary.isEmpty {
                SummaryView(summary: summary)
            }
            if !checkInImages.isEmpty {
                CheckInImagesSection(checkInImages: checkInImages, page: $checkInImagesPage, onLoadMore: {
                    await fetchImages(reset: false)
                })
            }
        }
        .listRowSeparator(.hidden)
        CheckInListSegmentPickerView(showCheckInsFrom: $showCheckInsFrom)
        CheckInListContentView(checkIns: $checkIns, onLoadMore: { _ in
            await fetchCheckIns(segment: showCheckInsFrom)
        })
        .checkInLoadedFrom(.product)
        CheckInListLoadingIndicatorView(isLoading: $isLoading, isRefreshing: $isRefreshing)
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) { HStack {} }
        if state.isPopulated {
            ToolbarItemGroup(placement: .topBarTrailing) {
                AsyncButton("wishlist.add.label", systemImage: "star") {
                    await toggleWishlist()
                }
                .asyncButtonLoadingStyle(.plain)
                .symbolVariant(isOnWishlist ? .fill : .none)
                Menu {
                    ControlGroup {
                        ProductShareLinkView(product: product)
                        RouterLink("checkIn.create.label", systemImage: "plus", open: .sheet(.checkIn(.create(product: product, onCreation: { checkIn in
                            checkIns = [checkIn] + checkIns
                        }))))
                        .disabled(!profileModel.hasPermission(.canCreateCheckIns))
                        if profileModel.hasPermission(.canAddBarcodes) {
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
                        open: .screen(.subBrand(brandId: product.subBrand.brand.id, subBrandId: product.subBrand.id))
                    )
                    RouterLink("brand.screen.open", systemImage: "cart", open: .screen(.brand(product.subBrand.brand.id)))
                    RouterLink(
                        "company.screen.open",
                        systemImage: "network",
                        open: .screen(.company(product.subBrand.brand.brandOwner.id))
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
                    AdminRouterLink(open: .sheet(.productAdmin(id: id, onUpdate: { update in
                        product = .init(product: update)
                        await getProductData(isRefresh: true)
                    }, onDelete: { _ in
                        router.removeLast()
                    })))
                } label: {
                    Label("labels.menu", systemImage: "ellipsis")
                        .labelStyle(.iconOnly)
                }
            }
        }
    }

    private func onCreateCheckIn(checkIn: CheckIn.Joined) async {
        checkIns = [checkIn] + checkIns
        do {
            summary = try await repository.product.getSummaryById(id: id)
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to load product summary. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func getProductData(isRefresh: Bool = false) async {
        async let loadInitialCheckInsPromise: Void = fetchCheckIns(reset: true, segment: .everyone)
        async let productPromise = repository.product.getById(id: id)
        async let summaryPromise = repository.product.getSummaryById(id: id)
        async let wishlistPromise = repository.product.checkIfOnWishlist(id: id)
        async let fetchImagePromise: Void = fetchImages(reset: true)
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
                state = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .getState(error: error, withHaptics: isRefresh, feedbackModel: feedbackModel)
            logger.error("Failed to load product summary. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func addBarcodeToProduct(_ barcode: Barcode) async {
        do {
            try await repository.productBarcode.addToProduct(id: id, barcode: barcode)
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
                checkInImages = []
                checkInImagesPage = 0
            }
        }
        let (from, to) = getPagination(page: checkInImagesPage, size: 10)

        do {
            let checkIns = try await repository.checkIn.getProductCheckInImages(productId: id, from: from, to: to)
            withAnimation {
                checkInImages.append(contentsOf: checkIns)
            }
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Fetching check-in images failed. Description: \(error.localizedDescription). Error: \(error) (\(#file):\(#line))")
        }
    }

    private func toggleWishlist() async {
        if isOnWishlist {
            do {
                try await repository.product.removeFromWishlist(productId: id)
                feedbackModel.trigger(.notification(.success))
                withAnimation {
                    isOnWishlist = false
                }
            } catch {
                guard !error.isCancelled else { return }
                logger.error("Removing from wishlist failed. Error: \(error) (\(#file):\(#line))")
            }
        } else {
            do { try await repository.product.addToWishlist(productId: id)
                feedbackModel.trigger(.notification(.success))
                withAnimation {
                    isOnWishlist = true
                }
            } catch {
                guard !error.isCancelled else { return }
                logger.error("Adding to wishlist failed. Error: \(error) (\(#file):\(#line))")
            }
        }
    }

    func fetchCheckIns(reset: Bool = false, segment: CheckIn.Segment) async {
        let (from, to) = getPagination(page: reset ? 0 : page, size: appModel.rateControl.checkInPageSize)
        isLoading = true
        let startTime = DispatchTime.now()
        do {
            let fetchedCheckIns = try await repository.checkIn.getByProductId(id: id, segment: segment, from: from, to: to)
            if reset {
                checkIns = fetchedCheckIns
            } else {
                checkIns.append(contentsOf: fetchedCheckIns)
            }
            page += 1
            logger.info("Fetching check-ins for product succesful in \(startTime.elapsedTime())ms")
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Fetching check-ins from \(from) to \(to) failed. Error: \(error) (\(#file):\(#line))")
            guard !error.isNetworkUnavailable else { return }
        }
        isLoading = false
    }
}
