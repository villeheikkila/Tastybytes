import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

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

    @State private var showBrandUnverificationConfirmation = false
    @State private var state: ScreenState = .loading

    let initialScrollPosition: SubBrand.JoinedBrand?

    init(
        brand: Brand.JoinedSubBrandsProductsCompany,
        initialScrollPosition: SubBrand.JoinedBrand? = nil
    ) {
        _brand = State(wrappedValue: brand)
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
        ScrollViewReader { proxy in
            List {
                if state == .populated {
                    populatedContent
                }
            }
            .listStyle(.plain)
            .refreshable {
                await getBrandData(withHaptics: true)
            }
            .overlay {
                if state == .populated, brand.subBrands.isEmpty {
                    ContentUnavailableView("brand.screen.empty.title", systemImage: "tray")
                } else {
                    ScreenStateOverlayView(state: state, errorDescription: "brand.screen.failedToLoad \(brand.name)", errorAction: {
                        await getBrandData(withHaptics: true)
                    })
                }
            }
            .initialTask {
                await getBrandData(proxy: proxy)
            }
            .navigationTitle(brand.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
        }
    }

    @ViewBuilder private var populatedContent: some View {
        SummaryView(summary: summary)
        switch productGrouping {
        case .subBrand:
            subBrandList
        case .category:
            groupedByCategoryList
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
                SubBrandSectionHeader(brand: $brand, subBrand: subBrand)
            }
            .headerProminence(.increased)
            .id(subBrand.id)
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
            Menu {
                ControlGroup {
                    BrandShareLinkView(brand: brand)
                    if profileEnvironmentModel.hasPermission(.canCreateProducts) {
                        RouterLink("brand.addProduct.menu.label", systemImage: "plus", open: .sheet(.product(.addToBrand(brand, onCreate: { product in
                            router.open(.screen(.product(product), removeLast: true))
                        }))))
                    }
                    Button("brand.product.groupBy.label", systemImage: "list.bullet.indent") {
                        showProductGroupingPicker = true
                    }
                }
                Divider()
                RouterLink(
                    "company.screen.open",
                    systemImage: "network",
                    open: .screen(.company(brand.brandOwner))
                )
                Divider()
                ReportButton(entity: .brand(brand))
                Divider()
                AdminRouterLink(open: .sheet(.brandAdmin(brand: brand, onUpdate: { updatedBrand in brand = updatedBrand }, onDelete: { _ in
                    router.removeLast()
                })))
            } label: {
                Label("labels.menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
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
        }
    }

    func getBrandData(withHaptics: Bool = false, proxy: ScrollViewProxy? = nil) async {
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
        var errors = [Error]()
        switch summaryResult {
        case let .success(summary):
            self.summary = summary
        case let .failure(error):
            guard !error.isCancelled else { return }
            errors.append(error)
            logger.error("Failed to load summary for brand. Error: \(error) (\(#file):\(#line))")
        }

        switch brandResult {
        case let .success(brand):
            self.brand = brand
        case let .failure(error):
            guard !error.isCancelled else { return }
            errors.append(error)
            logger.error("Request for brand with \(brandId) failed. Error: \(error) (\(#file):\(#line))")
        }

        switch isLikedPromiseResult {
        case let .success(isLikedByCurrentUser):
            withAnimation {
                self.isLikedByCurrentUser = isLikedByCurrentUser
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            errors.append(error)
            logger.error("Request to check if brand is liked failed. Error: \(error) (\(#file):\(#line))")
        }

        state = .getState(errors: errors, withHaptics: withHaptics, feedbackEnvironmentModel: feedbackEnvironmentModel)

        if let initialScrollPosition, let proxy {
            try? await Task.sleep(for: .milliseconds(100))
            proxy.scrollTo(initialScrollPosition.id, anchor: .top)
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

struct SubBrandSectionHeader: View {
    @Environment(Router.self) private var router
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Binding var brand: Brand.JoinedSubBrandsProductsCompany
    let subBrand: SubBrand.JoinedProduct

    var body: some View {
        HStack {
            if let name = subBrand.name {
                Text(name)
            }
            Spacer()
            Menu {
                if profileEnvironmentModel.hasPermission(.canCreateProducts) {
                    RouterLink(
                        "brand.createProduct.label",
                        systemImage: "plus",
                        open: .sheet(.product(.addToSubBrand(brand, subBrand, onCreate: { newProduct in
                            router.open(.screen(.product(newProduct), removeLast: true))
                        })))
                    )
                }
                Divider()
                ReportButton(entity: .subBrand(.init(brand: brand, subBrand: subBrand)))
                Divider()
                AdminRouterLink(open: .sheet(.subBrandAdmin(brand: $brand, subBrand: subBrand))
                )
            } label: {
                Label("labels.menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
                    .frame(width: 24, height: 24)
            }
        }
    }
}
