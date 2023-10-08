import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

private let logger = Logger(category: "BrandScreen")

struct BrandScreen: View {
    @Environment(\.repository) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(Router.self) private var router
    @State private var brand: Brand.JoinedSubBrandsProductsCompany
    @State private var summary: Summary?
    @State private var isLikedByCurrentUser = false
    @State private var productGrouping: GroupProductsBy = .subBrand
    @State private var showProductGroupingPicker = false
    @State private var toUnverifySubBrand: SubBrand.JoinedProduct? {
        didSet {
            showSubBrandUnverificationConfirmation = true
        }
    }

    @State private var showSubBrandUnverificationConfirmation = false
    @State private var showBrandUnverificationConfirmation = false

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

    private var sortedSubBrands: [SubBrand.JoinedProduct] {
        brand.subBrands
            .filter { !($0.name == nil && $0.products.isEmpty) }
            .sorted()
    }

    private var productsByCategory: [ProductsByCategory] {
        brand.subBrands.flatMap { subBrand in
            subBrand.products.map { product in
                Product.Joined(
                    product: product,
                    subBrand: subBrand,
                    brand: brand
                )
            }
        }
        .reduce(into: [ProductsByCategory]()) { result, product in
            if let index = result.firstIndex(where: { $0.category == product.category }) {
                result[index].products.append(product)
            } else {
                result.append(ProductsByCategory(category: product.category, products: [product]))
            }
        }
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            List {
                Section {
                    SummaryView(summary: summary)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .onAppear {
                    if let initialScrollPosition {
                        scrollProxy.scrollTo(initialScrollPosition.id, anchor: .top)
                    }
                }

                switch productGrouping {
                case .subBrand:
                    subBrandList
                case .category:
                    groupedByCategoryList
                }
            }
            .listStyle(.plain)
            #if !targetEnvironment(macCatalyst)
                .refreshable {
                    await feedbackEnvironmentModel.wrapWithHaptics {
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
            .confirmationDialog("Group products by",
                                isPresented: $showProductGroupingPicker,
                                titleVisibility: .visible)
            {
                Button("Sub-brand") {
                    productGrouping = .subBrand
                }
                .disabled(productGrouping == .subBrand)
                Button("Category") {
                    productGrouping = .category
                }
                .disabled(productGrouping == .category)
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

    @ViewBuilder private var groupedByCategoryList: some View {
        ForEach(productsByCategory) { category in
            Section(category.category.label) {
                ForEach(category.products) { product in
                    ProductRow(product: product)
                }
            }
            .headerProminence(.increased)
        }
    }

    @ViewBuilder private var subBrandList: some View {
        ForEach(sortedSubBrands) { subBrand in
            Section {
                ForEach(subBrand.products) { product in
                    ProductRow(product: Product.Joined(
                        product: product,
                        subBrand: subBrand,
                        brand: brand
                    ))
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
                        if profileEnvironmentModel.hasPermission(.canCreateProducts) {
                            RouterLink(
                                "Add Product",
                                systemImage: "plus",
                                sheet: .addProductToSubBrand(brand: brand, subBrand: subBrand)
                            )
                        }
                        if profileEnvironmentModel.hasPermission(.canEditBrands), subBrand.name != nil {
                            RouterLink(
                                "Edit",
                                systemImage: "pencil",
                                sheet: .editSubBrand(brand: brand, subBrand: subBrand, onUpdate: {
                                    await refresh()
                                })
                            )
                        }
                        ReportButton(entity: .subBrand(brand, subBrand))
                        if profileEnvironmentModel.hasPermission(.canDeleteBrands) {
                            Button(
                                "Delete",
                                systemImage: "trash.fill",
                                role: .destructive,
                                action: { toDeleteSubBrand = subBrand }
                            )
                            .disabled(subBrand.isVerified)
                        }
                    } label: {
                        Label("Options menu", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .headerProminence(.increased)
            .id(subBrand.id)
        }
    }

    @MainActor
    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(alignment: .center, spacing: 18) {
                if let logoUrl = brand.logoUrl {
                    RemoteImage(url: logoUrl) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 32, height: 32)
                                .accessibility(hidden: true)
                        } else {
                            ProgressView()
                        }
                    }
                }
                Text(brand.name)
                    .font(.headline)
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            ProgressButton(isLikedByCurrentUser ? "Unlike" : "Like", systemImage: "heart", action: {
                await toggleLike()
            })
            .symbolVariant(isLikedByCurrentUser ? .fill : .none)
            BrandShareLinkView(brand: brand)
            Menu {
                ControlGroup {
                    BrandShareLinkView(brand: brand)
                    if profileEnvironmentModel.hasPermission(.canCreateProducts) {
                        RouterLink("Product", systemImage: "plus", sheet: .addProductToBrand(brand: brand))
                    }
                    if profileEnvironmentModel.hasPermission(.canEditBrands) {
                        RouterLink("Edit", systemImage: "pencil", sheet: .editBrand(brand: brand, onUpdate: {
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
                RouterLink(
                    "Open Brand Owner",
                    systemImage: "network",
                    screen: .company(brand.brandOwner)
                )
                Divider()
                Button("Group Products By", systemImage: "list.bullet.indent") {
                    showProductGroupingPicker = true
                }
                ReportButton(entity: .brand(brand))
                if profileEnvironmentModel.hasPermission(.canDeleteBrands) {
                    Button(
                        "Delete",
                        systemImage: "trash.fill",
                        role: .destructive,
                        action: { showDeleteBrandConfirmationDialog = true }
                    )
                    .disabled(brand.isVerified)
                }
            } label: {
                Label("Options menu", systemImage: "ellipsis")
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
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to load summary for brand. Error: \(error) (\(#file):\(#line))")
        }

        switch await brandPromise {
        case let .success(brand):
            await MainActor.run {
                self.brand = brand
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
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
            feedbackEnvironmentModel.toggle(.error(.unexpected))
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
            feedbackEnvironmentModel.toggle(.error(.unexpected))
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
            feedbackEnvironmentModel.trigger(.notification(.success))
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to verify brand'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func toggleLike() async {
        if isLikedByCurrentUser {
            switch await repository.brand.unlikeBrand(brandId: brand.id) {
            case .success:
                feedbackEnvironmentModel.trigger(.notification(.success))
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
                feedbackEnvironmentModel.trigger(.notification(.success))
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
            feedbackEnvironmentModel.trigger(.notification(.success))
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to verify brand'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteBrand(_ brand: Brand.JoinedSubBrandsProductsCompany) async {
        switch await repository.brand.delete(id: brand.id) {
        case .success:
            router.reset()
            feedbackEnvironmentModel.trigger(.notification(.success))
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to delete brand. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteSubBrand(_: SubBrand.JoinedProduct) async {
        guard let toDeleteSubBrand else { return }
        switch await repository.subBrand.delete(id: toDeleteSubBrand.id) {
        case .success:
            await refresh()
            feedbackEnvironmentModel.trigger(.notification(.success))
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to delete brand '\(toDeleteSubBrand.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}

private struct ProductRow: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.repository) private var repository
    @Environment(Router.self) private var router
    @State private var showDeleteProductConfirmationDialog = false
    @State private var productToDelete: Product.Joined? {
        didSet {
            if productToDelete != nil {
                showDeleteProductConfirmationDialog = true
            }
        }
    }

    let product: Product.Joined

    var body: some View {
        RouterLink(screen: .product(product)) {
            ProductItemView(product: product)
                .padding(2)
                .contextMenu {
                    RouterLink(sheet: .duplicateProduct(
                        mode: profileEnvironmentModel
                            .hasPermission(.canMergeProducts) ? .mergeDuplicate : .reportDuplicate,
                        product: product
                    ), label: {
                        if profileEnvironmentModel.hasPermission(.canMergeProducts) {
                            Label("Merge to...", systemImage: "doc.on.doc")
                        } else {
                            Label("Mark as Duplicate", systemImage: "doc.on.doc")
                        }
                    })

                    if profileEnvironmentModel.hasPermission(.canDeleteProducts) {
                        Button(
                            "Delete",
                            systemImage: "trash.fill",
                            role: .destructive,
                            action: { productToDelete = product }
                        )
                        .foregroundColor(.red)
                        .disabled(product.isVerified)
                    }
                }
        }
        .confirmationDialog("Are you sure you want to delete the product and all of its check-ins?",
                            isPresented: $showDeleteProductConfirmationDialog,
                            titleVisibility: .visible,
                            presenting: productToDelete)
        { presenting in
            ProgressButton(
                "Delete \(presenting.getDisplayName(.fullName))",
                role: .destructive,
                action: { await deleteProduct(presenting) }
            )
        }
    }

    func deleteProduct(_ product: Product.Joined) async {
        switch await repository.product.delete(id: product.id) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            await MainActor.run {
                router.removeLast()
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to delete product \(product.id). Error: \(error) (\(#file):\(#line))")
        }
    }
}

private struct ProductsByCategory: Identifiable {
    var id: Int {
        category.id
    }

    let category: Models.Category
    var products: [Product.Joined]
}

private enum GroupProductsBy: String, CaseIterable {
    case subBrand, category
}
