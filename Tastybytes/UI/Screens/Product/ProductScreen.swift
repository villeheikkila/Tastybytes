import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

private let logger = Logger(category: "ProductScreen")

struct ProductScreen: View {
    @Environment(\.repository) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(Router.self) private var router
    @State private var scrollToTop: Int = 0
    @State private var product: Product.Joined
    @State private var summary: Summary?
    @State private var showDeleteProductConfirmationDialog = false
    @State private var showUnverifyProductConfirmation = false
    @State private var resetView: Int = 0

    @State private var loadedWithBarcode: Barcode?
    @State private var alertError: AlertError?

    // check-in images
    @State private var checkInImages = [CheckIn.Image]()
    @State private var isLoadingCheckInImages = false
    @State private var checkInImagesPage = 0

    // wishlist
    @State private var isOnWishlist = false

    init(product: Product.Joined, loadedWithBarcode: Barcode? = nil) {
        _product = State(wrappedValue: product)
        _loadedWithBarcode = State(wrappedValue: loadedWithBarcode)
    }

    var body: some View {
        CheckInListView(
            fetcher: .product(product),
            scrollToTop: $scrollToTop,
            onRefresh: {
                await refresh()
            },
            header: {
                headerContent
            }
        )
        .id(resetView)
        .if(loadedWithBarcode != nil, transform: { view in
            view.overlay(
                loadedFromBarcodeOverlay
            )
        })
        .task {
            if summary == nil {
                await loadSummary()
            }
        }
        .task {
            await fetchImages()
        }
        .task {
            await getIfIsOnWishlist()
        }
        .toolbar {
            toolbarContent
        }
        .alertError($alertError)
        .confirmationDialog("Unverify Product",
                            isPresented: $showUnverifyProductConfirmation,
                            presenting: product)
        { presenting in
            ProgressButton("Unverify \(presenting.name) product", role: .destructive, action: {
                await verifyProduct(product: presenting, isVerified: false)
            })
        }
        .confirmationDialog("Are you sure you want to delete the product and all of its check-ins?",
                            isPresented: $showDeleteProductConfirmationDialog,
                            titleVisibility: .visible,
                            presenting: product)
        { presenting in
            ProgressButton(
                "Delete \(presenting.getDisplayName(.fullName))",
                role: .destructive,
                action: { await deleteProduct(presenting) }
            )
        }
    }

    @ViewBuilder private var headerContent: some View {
        VStack {
            if loadedWithBarcode != nil {
                Spacer(minLength: 50)
            }
            ProductItemView(product: product, extras: [.companyLink, .logo])
            SummaryView(summary: summary).padding(.top, 4)
            HStack(spacing: 0) {
                RouterLink(
                    "Check-in!",
                    systemImage: "checkmark.circle",
                    sheet: .newCheckIn(product, onCreation: { _ in
                        await refreshCheckIns()
                    }),
                    asTapGesture: true
                )
                .frame(maxWidth: .infinity)
                .padding(.all, 6.5)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(4, corners: [.topLeft, .bottomLeft])
                ProgressButton("Wishlist", systemImage: "star", actionOptions: []) {
                    await toggleWishlist()
                }
                .symbolVariant(isOnWishlist ? .fill : .none)
                .frame(maxWidth: .infinity)
                .padding(.all, 6)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(3, corners: [.topRight, .bottomRight])
            }.padding(.top, 4)

            if !checkInImages.isEmpty {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(checkInImages) { checkInImage in
                            CheckInImageCellView(checkInImage: checkInImage)
                                .onAppear {
                                    if checkInImage == checkInImages.last, isLoadingCheckInImages != true {
                                        Task {
                                            await fetchImages()
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        }.padding(.horizontal)
    }

    @ViewBuilder private var loadedFromBarcodeOverlay: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Not the product you were looking for?")
                    HStack {
                        Button("Back to search") {
                            router.removeLast()
                        }
                    }
                }
                .padding(.vertical, 10)
                Spacer()
                CloseButtonView {
                    loadedWithBarcode = nil
                }
                .labelStyle(.iconOnly)
                .imageScale(.large)
            }
            .padding(.horizontal, 10)
            .background(.thinMaterial)
            Spacer()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            ProductShareLinkView(product: product)
            Menu {
                ControlGroup {
                    RouterLink("Check-in", systemImage: "plus", sheet: .newCheckIn(product, onCreation: { _ in
                        await refreshCheckIns()
                    }))
                    .disabled(!profileEnvironmentModel.hasPermission(.canCreateCheckIns))
                    ProductShareLinkView(product: product)
                    if profileEnvironmentModel.hasPermission(.canAddBarcodes) {
                        RouterLink(
                            "Add",
                            systemImage: "barcode.viewfinder",
                            sheet: .barcodeScanner(onComplete: { barcode in
                                Task { await addBarcodeToProduct(barcode) }
                            })
                        )
                    }
                }
                VerificationButton(isVerified: product.isVerified, verify: {
                    await verifyProduct(product: product, isVerified: true)
                }, unverify: {
                    showUnverifyProductConfirmation = true
                })
                Divider()
                RouterLink("Open Product", systemImage: "grid", screen: .product(product))
                RouterLink(
                    "Open Sub-brand",
                    systemImage: "cart",
                    screen: .fetchSubBrand(product.subBrand)
                )
                RouterLink("Open Brand", systemImage: "cart", screen: .fetchBrand(product.subBrand.brand))
                RouterLink(
                    "Open Brand Owner",
                    systemImage: "network",
                    screen: .company(product.subBrand.brand.brandOwner)
                )
                Divider()
                if profileEnvironmentModel.hasPermission(.canEditCompanies) {
                    RouterLink("Edit", systemImage: "pencil", sheet: .productEdit(product: product, onEdit: {
                        await refresh()
                    }))
                } else {
                    RouterLink(
                        "Edit Suggestion",
                        systemImage: "pencil",
                        sheet: .productEditSuggestion(product: product)
                    )
                }

                RouterLink(sheet: .duplicateProduct(
                    mode: profileEnvironmentModel.hasPermission(.canMergeProducts) ? .mergeDuplicate : .reportDuplicate,
                    product: product
                ), label: {
                    if profileEnvironmentModel.hasPermission(.canMergeProducts) {
                        Label("Merge to...", systemImage: "doc.on.doc")
                    } else {
                        Label("Mark as Duplicate", systemImage: "doc.on.doc")
                    }
                })

                Menu {
                    if profileEnvironmentModel.hasPermission(.canDeleteBarcodes) {
                        RouterLink("Barcodes", systemImage: "barcode", sheet: .barcodeManagement(product: product))
                    }

                    if profileEnvironmentModel.hasPermission(.canAddProductLogo) {
                        RouterLink("Edit Logo", systemImage: "photo", sheet: .productLogo(product: product, onUpload: {
                            await refresh()
                        }))
                    }

                    if profileEnvironmentModel.hasPermission(.canDeleteProducts) {
                        Button(
                            "Delete",
                            systemImage: "trash.fill",
                            role: .destructive,
                            action: { showDeleteProductConfirmationDialog = true }
                        )
                        .disabled(product.isVerified)
                    }
                } label: {
                    Label("Admin", systemImage: "gear")
                        .labelStyle(.iconOnly)
                }

                ReportButton(entity: .product(product))
            } label: {
                Label("Options menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
        }
    }

    func loadSummary() async {
        switch await repository.product.getSummaryById(id: product.id) {
        case let .success(summary):
            self.summary = summary
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("Failed to load product summary. Error: \(error) (\(#file):\(#line))")
        }
    }

    func getIfIsOnWishlist() async {
        switch await repository.product.checkIfOnWishlist(id: product.id) {
        case let .success(isOnWishlist):
            await MainActor.run {
                withAnimation {
                    self.isOnWishlist = isOnWishlist
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("Failed to load wishlist status. Error: \(error) (\(#file):\(#line))")
        }
    }

    func refresh() async {
        async let productPromise = repository.product.getById(id: product.id)
        async let summaryPromise = repository.product.getSummaryById(id: product.id)

        switch await productPromise {
        case let .success(refreshedProduct):
            await MainActor.run {
                withAnimation {
                    product = refreshedProduct
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("Failed to refresh product by id. Error: \(error) (\(#file):\(#line))")
        }

        switch await summaryPromise {
        case let .success(summary):
            await MainActor.run {
                self.summary = summary
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("Failed to load product summary. Error: \(error) (\(#file):\(#line))")
        }
    }

    func refreshCheckIns() async {
        resetView += 1
        await loadSummary()
    }

    func toggleWishlist() async {
        if isOnWishlist {
            switch await repository.product.removeFromWishlist(productId: product.id) {
            case .success:
                feedbackEnvironmentModel.trigger(.notification(.success))
                await MainActor.run {
                    withAnimation {
                        isOnWishlist = false
                    }
                }
            case let .failure(error):
                guard !error.localizedDescription.contains("cancelled") else { return }
                logger.error("removing from wishlist failed. Error: \(error) (\(#file):\(#line))")
            }
        } else {
            switch await repository.product.addToWishlist(productId: product.id) {
            case .success:
                feedbackEnvironmentModel.trigger(.notification(.success))
                await MainActor.run {
                    withAnimation {
                        isOnWishlist = true
                    }
                }
            case let .failure(error):
                guard !error.localizedDescription.contains("cancelled") else { return }
                logger.error("adding to wishlist failed. Error: \(error) (\(#file):\(#line))")
            }
        }
    }

    func verifyProduct(product: Product.Joined, isVerified: Bool) async {
        switch await repository.product.verification(id: product.id, isVerified: isVerified) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            await refresh()
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
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
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("Failed to delete product. Error: \(error) (\(#file):\(#line))")
        }
    }

    func addBarcodeToProduct(_ barcode: Barcode) async {
        switch await repository.productBarcode.addToProduct(product: product, barcode: barcode) {
        case .success:
            feedbackEnvironmentModel.toggle(.success("Barcode added!"))
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("adding barcode \(barcode.barcode) to product failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func fetchImages() async {
        let (from, to) = getPagination(page: checkInImagesPage, size: 10)
        isLoadingCheckInImages = true

        switch await repository.checkIn.getCheckInImages(by: .product(product), from: from, to: to) {
        case let .success(checkIns):
            await MainActor.run {
                withAnimation {
                    self.checkInImages.append(contentsOf: checkIns)
                }
                checkInImagesPage += 1
                isLoadingCheckInImages = false
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger
                .error(
                    "Fetching check-in images failed. Description: \(error.localizedDescription). Error: \(error) (\(#file):\(#line))"
                )
        }
    }
}
