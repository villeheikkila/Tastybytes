import OSLog
import SwiftUI

private let logger = Logger(category: "ProductScreen")

struct ProductScreen: View {
    @Environment(Repository.self) private var repository
    @Environment(ProfileManager.self) private var profileManager
    @Environment(FeedbackManager.self) private var feedbackManager
    @Environment(Router.self) private var router
    @State private var scrollToTop: Int = 0
    @State private var product: Product.Joined
    @State private var summary: Summary?
    @State private var showDeleteProductConfirmationDialog = false
    @State private var showUnverifyProductConfirmation = false
    @State private var resetView: Int = 0

    // check-in images
    @State private var checkInImages = [CheckIn.Image]()
    @State private var isLoadingCheckInImages = false
    @State private var checkInImagesPage = 0

    init(product: Product.Joined) {
        _product = State(wrappedValue: product)
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
        .task {
            if summary == nil {
                await loadSummary()
            }
        }
        .task {
            await fetchImages()
        }
        .toolbar {
            toolbarContent
        }
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
        Group {
            ProductItemView(product: product, extras: [.companyLink, .logo])
            SummaryView(summary: summary)
            RouterLink("Check-in!", sheet: .newCheckIn(product, onCreation: { _ in
                await refreshCheckIns()
            }))
            .fontWeight(.semibold)
            .padding(.all, 8)
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
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
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
        .listRowSeparator(.hidden)
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu {
                ControlGroup {
                    RouterLink("Check-in", systemSymbol: .plus, sheet: .newCheckIn(product, onCreation: { _ in
                        await refreshCheckIns()
                    }))
                    .disabled(!profileManager.hasPermission(.canCreateCheckIns))
                    ProductShareLinkView(product: product)
                    if profileManager.hasPermission(.canAddBarcodes) {
                        RouterLink(
                            "Add",
                            systemSymbol: .barcodeViewfinder,
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
                if profileManager.hasPermission(.canEditCompanies) {
                    RouterLink("Edit", systemSymbol: .pencil, sheet: .productEdit(product: product))
                } else {
                    RouterLink(
                        "Edit Suggestion",
                        systemSymbol: .pencil,
                        sheet: .productEditSuggestion(product: product)
                    )
                }

                RouterLink(sheet: .duplicateProduct(
                    mode: profileManager.hasPermission(.canMergeProducts) ? .mergeDuplicate : .reportDuplicate,
                    product: product
                ), label: {
                    if profileManager.hasPermission(.canMergeProducts) {
                        Label("Merge to...", systemSymbol: .docOnDoc)
                    } else {
                        Label("Mark as Duplicate", systemSymbol: .docOnDoc)
                    }
                })

                Menu {
                    if profileManager.hasPermission(.canDeleteBarcodes) {
                        RouterLink("Barcodes", systemSymbol: .barcode, sheet: .barcodeManagement(product: product))
                    }

                    if profileManager.hasPermission(.canAddProductLogo) {
                        RouterLink("Edit Logo", systemSymbol: .photo, sheet: .productLogo(product: product, onUpload: {
                            await refresh()
                        }))
                    }

                    if profileManager.hasPermission(.canDeleteProducts) {
                        Button(
                            "Delete",
                            systemSymbol: .trashFill,
                            role: .destructive,
                            action: { showDeleteProductConfirmationDialog = true }
                        )
                        .disabled(product.isVerified)
                    }
                } label: {
                    Label("Admin", systemSymbol: .gear)
                        .labelStyle(.iconOnly)
                }

                ReportButton(entity: .product(product))
            } label: {
                Label("Options menu", systemSymbol: .ellipsis)
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
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to load product summary. Error: \(error) (\(#file):\(#line))")
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
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to refresh product by id. Error: \(error) (\(#file):\(#line))")
        }

        switch await summaryPromise {
        case let .success(summary):
            await MainActor.run {
                self.summary = summary
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to load product summary. Error: \(error) (\(#file):\(#line))")
        }
    }

    func refreshCheckIns() async {
        resetView += 1
        await loadSummary()
    }

    func verifyProduct(product: Product.Joined, isVerified: Bool) async {
        switch await repository.product.verification(id: product.id, isVerified: isVerified) {
        case .success:
            feedbackManager.trigger(.notification(.success))
            await refresh()
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to verify product. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteProduct(_ product: Product.Joined) async {
        switch await repository.product.delete(id: product.id) {
        case .success:
            feedbackManager.trigger(.notification(.success))
            router.removeLast()
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to delete product. Error: \(error) (\(#file):\(#line))")
        }
    }

    func addBarcodeToProduct(_ barcode: Barcode) async {
        switch await repository.productBarcode.addToProduct(product: product, barcode: barcode) {
        case .success:
            feedbackManager.toggle(.success("Barcode added!"))
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
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
            feedbackManager.toggle(.error(.unexpected))
            logger
                .error(
                    "Fetching check-in images failed. Description: \(error.localizedDescription). Error: \(error) (\(#file):\(#line))"
                )
        }
    }
}
