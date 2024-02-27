import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct BrandScreen: View {
    private let logger = Logger(category: "BrandScreen")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(Router.self) private var router
    @State private var brand: Brand.JoinedSubBrandsProductsCompany
    @State private var summary: Summary?
    @State private var isLikedByCurrentUser = false
    @State private var productGrouping: GroupProductsBy = .subBrand
    @State private var showProductGroupingPicker = false
    @State private var toUnverifySubBrand: SubBrand.JoinedProduct?

    @State private var showBrandUnverificationConfirmation = false
    @State private var alertError: AlertError?
    @State private var showDeleteBrandConfirmationDialog = false
    @State private var toDeleteSubBrand: SubBrand.JoinedProduct?

    @State private var refreshId = 0
    @State private var resultId: Int?
    @State private var sheet: Sheet?

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
                result.append(.init(category: product.category, products: [product]))
            }
        }
    }

    var body: some View {
        ScrollViewReader { _ in
            List {
                Section {
                    SummaryView(summary: summary)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .sheets(item: $sheet)

                switch productGrouping {
                case .subBrand:
                    subBrandList
                case .category:
                    groupedByCategoryList
                }
            }
            .listStyle(.plain)
            .refreshable {
                await getBrandData(withHaptics: true)
            }
            .initialTask {
                await getBrandData()
            }
            .toolbar {
                toolbarContent
            }
            .confirmationDialog(
                "subBrand.unverify",
                isPresented: $toUnverifySubBrand.isNotNull(),
                presenting: toUnverifySubBrand
            ) { presenting in
                ProgressButton(
                    "subBrand.unverify.disclaimer \(presenting.name ?? "subBrand.default.label")",
                    action: {
                        await verifySubBrand(presenting, isVerified: false)
                    }
                )
            }
            .alertError($alertError)
            .confirmationDialog(
                "brand.unverify.confirmation.title",
                isPresented: $showBrandUnverificationConfirmation,
                presenting: brand
            ) { presenting in
                ProgressButton(
                    "brand.unverify.confirmation.label \(presenting.name)",
                    action: {
                        await verifyBrand(brand: presenting, isVerified: false)
                    }
                )
            }
            .confirmationDialog(
                "brandScreen.groupProductsBy",
                isPresented: $showProductGroupingPicker,
                titleVisibility: .visible
            ) {
                Button("subBrand.title") {
                    productGrouping = .subBrand
                }
                .disabled(productGrouping == .subBrand)
                Button("category.title") {
                    productGrouping = .category
                }
                .disabled(productGrouping == .category)
            }
            .confirmationDialog(
                "subBrand.delete.disclaimer",
                isPresented: $toDeleteSubBrand.isNotNull(),
                titleVisibility: .visible,
                presenting: toDeleteSubBrand
            ) { presenting in
                ProgressButton(
                    "subBrand.delete \(presenting.name ?? "subBrand.default.label")",
                    role: .destructive,
                    action: {
                        await deleteSubBrand(presenting)
                    }
                )
            }
        }
    }

    @ViewBuilder private var groupedByCategoryList: some View {
        ForEach(productsByCategory) { category in
            Section(category.category.label) {
                ForEach(category.products) { product in
                    BrandScreenProductRow(product: product)
                }
            }
            .headerProminence(.increased)
        }
    }

    @ViewBuilder private var subBrandList: some View {
        ForEach(sortedSubBrands) { subBrand in
            Section {
                ForEach(subBrand.products) { product in
                    BrandScreenProductRow(
                        product: .init(
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
                        VerificationButton(
                            isVerified: subBrand.isVerified,
                            verify: {
                                await verifySubBrand(subBrand, isVerified: true)
                            },
                            unverify: {
                                toUnverifySubBrand = subBrand
                            }
                        )
                        Divider()
                        if profileEnvironmentModel.hasPermission(.canCreateProducts) {
                            Button(
                                "brand.createProduct.label",
                                systemImage: "plus",
                                action: {
                                    sheet = .addProductToSubBrand(brand: brand, subBrand: subBrand)
                                }
                            )
                        }
                        if profileEnvironmentModel.hasPermission(.canEditBrands), subBrand.name != nil {
                            Button(
                                "labels.edit",
                                systemImage: "pencil",
                                action: { sheet = .editSubBrand(
                                    brand: brand, subBrand: subBrand,
                                    onUpdate: { updatedSubBrand in
                                        let updatedSubBrands = brand.subBrands.replacing(subBrand, with: updatedSubBrand)
                                        brand = brand.copyWith(subBrands: updatedSubBrands)
                                    }
                                ) }
                            )
                        }
                        ReportButton(sheet: $sheet, entity: .subBrand(brand, subBrand))
                        if profileEnvironmentModel.hasPermission(.canDeleteBrands) {
                            Button(
                                "labels.delete",
                                systemImage: "trash.fill",
                                role: .destructive,
                                action: { toDeleteSubBrand = subBrand }
                            )
                            .disabled(subBrand.isVerified)
                        }
                    } label: {
                        Label("labels.menu", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .headerProminence(.increased)
            .id(subBrand)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(alignment: .center, spacing: 18) {
                if !brand.logos.isEmpty {
                    BrandLogo(brand: brand, size: 32)
                }
                Text(brand.name)
                    .font(.headline)
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            ProgressButton(
                isLikedByCurrentUser ? "labels.unlike" : "labels.like", systemImage: "heart",
                action: {
                    await toggleLike()
                }
            )
            .symbolVariant(isLikedByCurrentUser ? .fill : .none)
            BrandShareLinkView(brand: brand)
            Menu {
                ControlGroup {
                    BrandShareLinkView(brand: brand)
                    if profileEnvironmentModel.hasPermission(.canCreateProducts) {
                        Button("brand.addProduct.menu.label", systemImage: "plus", action: { sheet = .addProductToBrand(brand: brand) })
                    }
                    if profileEnvironmentModel.hasPermission(.canEditBrands) {
                        Button(
                            "labels.edit", systemImage: "pencil",
                            action: { sheet = .editBrand(
                                brand: brand,
                                onUpdate: { updatedBrand in
                                    brand = updatedBrand
                                }
                            ) }
                        )
                    }
                }
                VerificationButton(
                    isVerified: brand.isVerified,
                    verify: {
                        await verifyBrand(brand: brand, isVerified: true)
                    },
                    unverify: {
                        showBrandUnverificationConfirmation = true
                    }
                )
                Divider()
                RouterLink(
                    "company.screen.open",
                    systemImage: "network",
                    screen: .company(brand.brandOwner)
                )
                Divider()
                Button("brand.product.groupBy.label", systemImage: "list.bullet.indent") {
                    showProductGroupingPicker = true
                }
                ReportButton(sheet: $sheet, entity: .brand(brand))
                if profileEnvironmentModel.hasPermission(.canDeleteBrands) {
                    Button(
                        "labels.delete",
                        systemImage: "trash.fill",
                        role: .destructive,
                        action: { showDeleteBrandConfirmationDialog = true }
                    )
                    .disabled(brand.isVerified)
                }
            } label: {
                Label("labels.menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
            .confirmationDialog(
                "brand.delete.disclaimer",
                isPresented: $showDeleteBrandConfirmationDialog,
                titleVisibility: .visible,
                presenting: brand
            ) { presenting in
                ProgressButton(
                    "brand.delete.label \(presenting.name)", role: .destructive,
                    action: {
                        await deleteBrand(presenting)
                    }
                )
            }
        }
    }

    func getBrandData(withHaptics: Bool = false) async {
        let brandId = brand.id
        async let summaryPromise = repository.brand.getSummaryById(id: brandId)
        async let brandPromise = repository.brand.getJoinedById(id: brandId)
        async let isLikedPromisePromise = repository.brand.isLikedByCurrentUser(id: brandId)
        if withHaptics {
            feedbackEnvironmentModel.trigger(.impact(intensity: .low))
        }
        let (summaryResult, brandResult, isLikedPromiseResult) = await (
            summaryPromise,
            brandPromise,
            isLikedPromisePromise
        )
        switch summaryResult {
        case let .success(summary):
            self.summary = summary
            if withHaptics {
                feedbackEnvironmentModel.trigger(.impact(intensity: .high))
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to load summary for brand. Error: \(error) (\(#file):\(#line))")
        }

        switch brandResult {
        case let .success(brand):
            self.brand = brand
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Request for brand with \(brandId) failed. Error: \(error) (\(#file):\(#line))")
        }

        switch isLikedPromiseResult {
        case let .success(isLikedByCurrentUser):
            withAnimation {
                self.isLikedByCurrentUser = isLikedByCurrentUser
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Request to check if brand is liked failed. Error: \(error) (\(#file):\(#line))")
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
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to verify brand'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func toggleLike() async {
        if isLikedByCurrentUser {
            switch await repository.brand.unlikeBrand(brandId: brand.id) {
            case .success:
                feedbackEnvironmentModel.trigger(.notification(.success))
                withAnimation {
                    isLikedByCurrentUser = false
                }
            case let .failure(error):
                guard !error.isCancelled else { return }
                logger.error("Unliking brand failed. Error: \(error) (\(#file):\(#line))")
            }
        } else {
            switch await repository.brand.likeBrand(brandId: brand.id) {
            case .success:
                feedbackEnvironmentModel.trigger(.notification(.success))
                withAnimation {
                    isLikedByCurrentUser = true
                }
            case let .failure(error):
                guard !error.isCancelled else { return }
                logger.error("Liking a brand failed. Error: \(error) (\(#file):\(#line))")
            }
        }
    }

    func verifySubBrand(_ subBrand: SubBrand.JoinedProduct, isVerified: Bool) async {
        switch await repository.subBrand.verification(id: subBrand.id, isVerified: isVerified) {
        case .success:
            refreshId += 1
            feedbackEnvironmentModel.trigger(.notification(.success))
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to verify brand'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteBrand(_ brand: Brand.JoinedSubBrandsProductsCompany) async {
        switch await repository.brand.delete(id: brand.id) {
        case .success:
            router.reset()
            feedbackEnvironmentModel.trigger(.notification(.success))
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete brand. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteSubBrand(_: SubBrand.JoinedProduct) async {
        guard let toDeleteSubBrand else { return }
        switch await repository.subBrand.delete(id: toDeleteSubBrand.id) {
        case .success:
            refreshId += 1
            feedbackEnvironmentModel.trigger(.notification(.success))
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error(
                "Failed to delete brand '\(toDeleteSubBrand.id)'. Error: \(error) (\(#file):\(#line))")
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
