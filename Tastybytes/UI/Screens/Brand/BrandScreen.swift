import OSLog
import SwiftUI

private let logger = Logger(category: "BrandScreen")

struct BrandScreen: View {
    @Environment(Repository.self) private var repository
    @Environment(ProfileManager.self) private var profileManager
    @Environment(FeedbackManager.self) private var feedbackManager
    @Environment(Router.self) private var router
    @State private var brand: Brand.JoinedSubBrandsProductsCompany
    @State private var summary: Summary?
    @State private var isLikedByCurrentUser = false
    @State private var toUnverifySubBrand: SubBrand.JoinedProduct? {
        didSet {
            showSubBrandUnverificationConfirmation = true
        }
    }

    @State private var showSubBrandUnverificationConfirmation = false
    @State private var showBrandUnverificationConfirmation = false
    @State private var showDeleteProductConfirmationDialog = false
    @State private var productToDelete: Product.JoinedCategory? {
        didSet {
            if productToDelete != nil {
                showDeleteProductConfirmationDialog = true
            }
        }
    }

    @State private var showDeleteBrandConfirmationDialog = false
    @State private var brandToDelete: Brand.JoinedSubBrandsProducts? {
        didSet {
            showDeleteBrandConfirmationDialog = true
        }
    }

    @State private var showDeleteSubBrandConfirmation = false
    @State private var toDeleteSubBrand: SubBrand.JoinedProduct? {
        didSet {
            if oldValue == nil {
                showDeleteSubBrandConfirmation = true
            } else {
                showDeleteSubBrandConfirmation = false
            }
        }
    }

    let refreshOnLoad: Bool
    let initialScrollPosition: SubBrand.JoinedBrand?

    init(
        brand: Brand.JoinedSubBrandsProductsCompany,
        refreshOnLoad: Bool? = false,
        initialScrollPosition: SubBrand.JoinedBrand? = nil
    ) {
        _brand = State(wrappedValue: brand)
        self.refreshOnLoad = refreshOnLoad ?? false
        self.initialScrollPosition = initialScrollPosition
    }

    var sortedSubBrands: [SubBrand.JoinedProduct] {
        brand.subBrands
            .filter { !($0.name == nil && $0.products.isEmpty) }
            .sorted()
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            List {
                Section {
                    SummaryView(summary: summary)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                ForEach(sortedSubBrands) { subBrand in
                    Section {
                        ForEach(subBrand.products) { product in
                            let productJoined = Product.Joined(
                                product: product,
                                subBrand: subBrand,
                                brand: brand
                            )
                            RouterLink(screen: .product(productJoined)) {
                                ProductItemView(product: productJoined)
                                    .padding(2)
                                    .contextMenu {
                                        RouterLink(sheet: .duplicateProduct(
                                            mode: profileManager
                                                .hasPermission(.canMergeProducts) ? .mergeDuplicate : .reportDuplicate,
                                            product: productJoined
                                        ), label: {
                                            if profileManager.hasPermission(.canMergeProducts) {
                                                Label("Merge to...", systemSymbol: .docOnDoc)
                                            } else {
                                                Label("Mark as Duplicate", systemSymbol: .docOnDoc)
                                            }
                                        })

                                        if profileManager.hasPermission(.canDeleteProducts) {
                                            Button(
                                                "Delete",
                                                systemSymbol: .trashFill,
                                                role: .destructive,
                                                action: { productToDelete = product }
                                            )
                                            .foregroundColor(.red)
                                            .disabled(product.isVerified)
                                        }
                                    }
                            }
                        }
                    } header: {
                        HStack {
                            if let name = subBrand.name {
                                Text(name)
                            }
                            Spacer()
                            Menu {
                                VerificationButton(isVerified: subBrand.isVerified, verify: {
                                    await verifySubBrand(subBrand, isVerified: true)
                                }, unverify: {
                                    toUnverifySubBrand = subBrand
                                })
                                Divider()
                                if profileManager.hasPermission(.canCreateProducts) {
                                    RouterLink(
                                        "Add Product",
                                        systemSymbol: .plus,
                                        sheet: .addProductToSubBrand(brand: brand, subBrand: subBrand)
                                    )
                                }
                                if profileManager.hasPermission(.canEditBrands), subBrand.name != nil {
                                    RouterLink(
                                        "Edit",
                                        systemSymbol: .pencil,
                                        sheet: .editSubBrand(brand: brand, subBrand: subBrand, onUpdate: {
                                            await refresh()
                                        })
                                    )
                                }
                                ReportButton(entity: .subBrand(brand, subBrand))
                                if profileManager.hasPermission(.canDeleteBrands) {
                                    Button(
                                        "Delete",
                                        systemSymbol: .trashFill,
                                        role: .destructive,
                                        action: { toDeleteSubBrand = subBrand }
                                    )
                                    .disabled(subBrand.isVerified)
                                }
                            } label: {
                                Label("Options menu", systemSymbol: .ellipsis)
                                    .labelStyle(.iconOnly)
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                    .headerProminence(.increased)
                    .id(subBrand.id)
                }
                .onAppear {
                    if let initialScrollPosition {
                        scrollProxy.scrollTo(initialScrollPosition.id, anchor: .top)
                    }
                }
            }
            .listStyle(.plain)
            #if !targetEnvironment(macCatalyst)
                .refreshable {
                    await feedbackManager.wrapWithHaptics {
                        await refresh()
                    }
                }
            #endif
                .task {
                        await getIsLikedBy()
                    }
                    .task {
                        if summary == nil {
                            await getSummary()
                        }
                        if refreshOnLoad {
                            await refresh()
                        }
                    }
                    .toolbar {
                        toolbarContent
                    }
                    .confirmationDialog("Unverify Sub-brand",
                                        isPresented: $showSubBrandUnverificationConfirmation,
                                        presenting: toUnverifySubBrand)
            { presenting in
                ProgressButton("Unverify \(presenting.name ?? "default") sub-brand", action: {
                    await verifySubBrand(presenting, isVerified: false)
                })
            }
            .confirmationDialog("Unverify Brand",
                                isPresented: $showBrandUnverificationConfirmation,
                                presenting: brand)
            { presenting in
                ProgressButton("Unverify \(presenting.name) brand", action: {
                    await verifyBrand(brand: presenting, isVerified: false)
                })
            }
            .confirmationDialog("Are you sure you want to delete sub-brand and all related products?",
                                isPresented: $showDeleteSubBrandConfirmation,
                                titleVisibility: .visible,
                                presenting: toDeleteSubBrand)
            { presenting in
                ProgressButton(
                    "Delete \(presenting.name ?? "default sub-brand")",
                    role: .destructive,
                    action: {
                        await deleteSubBrand(presenting)
                    }
                )
            }
            .confirmationDialog("Are you sure you want to delete brand and all related sub-brands and products?",
                                isPresented: $showDeleteBrandConfirmationDialog,
                                titleVisibility: .visible,
                                presenting: brand)
            { presenting in
                ProgressButton("Delete \(presenting.name)", role: .destructive, action: {
                    await deleteBrand(presenting)
                })
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(alignment: .center, spacing: 18) {
                if let logoUrl = brand.logoUrl {
                    AsyncImage(url: logoUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                            .accessibility(hidden: true)
                    } placeholder: {
                        ProgressView()
                    }
                }
                Text(brand.name)
                    .font(.headline)
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            ProgressButton(isLikedByCurrentUser ? "Unlike" : "Like", systemSymbol: .heart, action: {
                await toggleLike()
            })
            .symbolVariant(isLikedByCurrentUser ? .fill : .none)
            Menu {
                ControlGroup {
                    BrandShareLinkView(brand: brand)
                    if profileManager.hasPermission(.canCreateProducts) {
                        RouterLink("Product", systemSymbol: .plus, sheet: .addProductToBrand(brand: brand))
                    }
                    if profileManager.hasPermission(.canEditBrands) {
                        RouterLink("Edit", systemSymbol: .pencil, sheet: .editBrand(brand: brand, onUpdate: {
                            await refresh()
                        }))
                    }
                }
                VerificationButton(isVerified: brand.isVerified, verify: {
                    await verifyBrand(brand: brand, isVerified: true)
                }, unverify: {
                    showBrandUnverificationConfirmation = true
                })
                Divider()
                ReportButton(entity: .brand(brand))
                if profileManager.hasPermission(.canDeleteBrands) {
                    Button(
                        "Delete",
                        systemSymbol: .trashFill,
                        role: .destructive,
                        action: { showDeleteBrandConfirmationDialog = true }
                    )
                    .disabled(brand.isVerified)
                }
            } label: {
                Label("Options menu", systemSymbol: .ellipsis)
                    .labelStyle(.iconOnly)
            }
        }
    }

    func refresh() async {
        let brandId = brand.id
        async let summaryPromise = repository.brand.getSummaryById(id: brandId)
        async let brandPromise = repository.brand.getJoinedById(id: brandId)
        async let isLikedPromisePromise = repository.brand.isLikedByCurrentUser(id: brandId)

        switch await summaryPromise {
        case let .success(summary):
            await MainActor.run {
                self.summary = summary
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to load summary for brand. Error: \(error) (\(#file):\(#line))")
        }

        switch await brandPromise {
        case let .success(brand):
            await MainActor.run {
                self.brand = brand
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Request for brand with \(brandId) failed. Error: \(error) (\(#file):\(#line))")
        }

        switch await isLikedPromisePromise {
        case let .success(isLikedByCurrentUser):
            await MainActor.run {
                withAnimation {
                    self.isLikedByCurrentUser = isLikedByCurrentUser
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            logger.error("Request to check if brand is liked failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func getSummary() async {
        async let summaryPromise = repository.brand.getSummaryById(id: brand.id)
        switch await summaryPromise {
        case let .success(summary):
            await MainActor.run {
                self.summary = summary
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to load summary for brand. Error: \(error) (\(#file):\(#line))")
        }
    }

    func getIsLikedBy() async {
        switch await repository.brand.isLikedByCurrentUser(id: brand.id) {
        case let .success(isLikedByCurrentUser):
            await MainActor.run {
                withAnimation {
                    self.isLikedByCurrentUser = isLikedByCurrentUser
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to load like status. Error: \(error) (\(#file):\(#line))")
        }
    }

    func verifyBrand(brand: Brand.JoinedSubBrandsProductsCompany, isVerified: Bool) async {
        switch await repository.brand.verification(id: brand.id, isVerified: isVerified) {
        case .success:
            self.brand = Brand.JoinedSubBrandsProductsCompany(
                id: brand.id,
                name: brand.name,
                isVerified: isVerified,
                brandOwner: brand.brandOwner,
                subBrands: brand.subBrands
            )
            feedbackManager.trigger(.notification(.success))
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to verify brand'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func toggleLike() async {
        if isLikedByCurrentUser {
            switch await repository.brand.unlikeBrand(brandId: brand.id) {
            case .success:
                feedbackManager.trigger(.notification(.success))
                await MainActor.run {
                    withAnimation {
                        self.isLikedByCurrentUser = false
                    }
                }
            case let .failure(error):
                guard !error.localizedDescription.contains("cancelled") else { return }
                logger.error("unliking brand failed. Error: \(error) (\(#file):\(#line))")
            }
        } else {
            switch await repository.brand.likeBrand(brandId: brand.id) {
            case .success:
                feedbackManager.trigger(.notification(.success))
                await MainActor.run {
                    withAnimation {
                        self.isLikedByCurrentUser = true
                    }
                }
            case let .failure(error):
                guard !error.localizedDescription.contains("cancelled") else { return }
                logger.error("liking brand failed. Error: \(error) (\(#file):\(#line))")
            }
        }
    }

    func verifySubBrand(_ subBrand: SubBrand.JoinedProduct, isVerified: Bool) async {
        switch await repository.subBrand.verification(id: subBrand.id, isVerified: isVerified) {
        case .success:
            await refresh()
            feedbackManager.trigger(.notification(.success))
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to verify brand'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteBrand(_ brand: Brand.JoinedSubBrandsProductsCompany) async {
        switch await repository.brand.delete(id: brand.id) {
        case .success:
            router.reset()
            feedbackManager.trigger(.notification(.success))
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to delete brand. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteSubBrand(_: SubBrand.JoinedProduct) async {
        guard let toDeleteSubBrand else { return }
        switch await repository.subBrand.delete(id: toDeleteSubBrand.id) {
        case .success:
            await refresh()
            feedbackManager.trigger(.notification(.success))
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to delete brand '\(toDeleteSubBrand.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
