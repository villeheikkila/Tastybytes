import Components

import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct BrandScreen: View {
    private let logger = Logger(category: "BrandScreen")
    @Environment(Repository.self) private var repository
    @Environment(ProfileModel.self) private var profileModel
    @Environment(FeedbackModel.self) private var feedbackModel
    @Environment(Router.self) private var router
    @State private var brand = Brand.JoinedSubBrandsCompany()
    @State private var summary: Summary?
    @State private var isLikedByCurrentUser = false
    @State private var productGrouping: GroupProductsBy = .subBrand
    @State private var showProductGroupingPicker = false
    @State private var state: ScreenState = .loading
    @State private var products = [Product.Joined]()

    let id: Brand.Id
    let initialScrollPosition: SubBrand.Id?

    private var productsBySubBrand: [SubBrand.JoinedProductJoined] {
        products
            .grouped(by: { $0.subBrand })
            .map { .init(subBrand: $0, products: $1) }
            .filter { !($0.name == nil && $0.products.isEmpty) }
            .sorted()
    }

    private var productsByCategory: [ProductsByCategory] {
        products
            .grouped(by: { $0.category })
            .map { .init(category: $0, products: $1) }
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                if state.isPopulated {
                    content
                }
            }
            .listStyle(.plain)
            .refreshable {
                await getBrandData(withHaptics: true)
            }
            .overlay {
                if state.isPopulated, products.isEmpty {
                    ContentUnavailableView("brand.screen.empty.title", systemImage: "tray")
                } else {
                    ScreenStateOverlayView(state: state, errorDescription: "brand.screen.failedToLoad \(brand.name)", errorAction: {
                        await getBrandData(withHaptics: true)
                    })
                }
            }
            .task {
                await getBrandData(proxy: proxy)
            }
            .navigationTitle(brand.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if state.isPopulated {
                    toolbarContent
                }
            }
        }
    }

    @ViewBuilder private var content: some View {
        SummaryView(summary: summary) {
            Divider()
            OutOfSummaryItem(
                title: "labels.hadOf",
                count: products.count { $0.isCheckedInByCurrentUser },
                of: products.count
            )
        }
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
                    BrandScreenProductRowView(product: product)
                }
            }
            .headerProminence(.increased)
        }
    }

    @ViewBuilder private var subBrandList: some View {
        ForEach(productsBySubBrand) { subBrand in
            Section {
                ForEach(subBrand.products) { product in
                    BrandScreenProductRowView(product: product)
                }
            } header: {
                SubBrandSectionHeaderView(brand: brand, subBrand: subBrand)
            }
            .headerProminence(.increased)
            .id(subBrand.id)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(alignment: .center, spacing: 18) {
                if !brand.logos.isEmpty {
                    BrandLogoView(brand: brand, size: 32)
                }
                Text(brand.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            AsyncButton(
                isLikedByCurrentUser ? "labels.unlike" : "labels.like", systemImage: "heart",
                action: {
                    await toggleLike()
                }
            )
            .symbolVariant(isLikedByCurrentUser ? .fill : .none)
            Menu {
                ControlGroup {
                    BrandShareLinkView(brand: brand)
                    if profileModel.hasPermission(.canCreateProducts) {
                        RouterLink("brand.addProduct.menu.label", systemImage: "plus", open: .sheet(.product(.addToBrand(brand, onCreate: { product in
                            router.open(.screen(.product(product.id), removeLast: true))
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
                    open: .screen(.company(brand.brandOwner.id))
                )
                Divider()
                RouterLink("labels.editSuggestion", systemImage: "pencil", open: .sheet(.brandEditSuggestion(brand: brand, onSuccess: {
                    router.open(.toast(.success("brand.editSuggestion.submitted")))
                })))
                ReportButton(entity: .brand(brand))
                Divider()
                AdminRouterLink(open: .sheet(.brandAdmin(id: id, onUpdate: { updatedBrand in
                    brand = .init(brand: updatedBrand)
                }, onDelete: { _ in
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

    private func getBrandData(withHaptics: Bool = false, proxy: ScrollViewProxy? = nil) async {
        async let summaryPromise = repository.brand.getSummaryById(id: id)
        async let brandPromise = repository.brand.getJoinedById(id: id)
        async let isLikedPromisePromise = repository.brand.isLikedByCurrentUser(id: id)
        async let productsPromise = repository.brand.getBrandProductsWithRating(id: id)
        if withHaptics {
            feedbackModel.trigger(.impact(intensity: .low))
        }
        do {
            let (summaryResult, brandResult, isLikedResult, productResults) = try await (
                summaryPromise,
                brandPromise,
                isLikedPromisePromise,
                productsPromise
            )
            withAnimation {
                summary = summaryResult
                brand = brandResult
                isLikedByCurrentUser = isLikedResult
                products = productResults
                state = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .getState(error: error, withHaptics: withHaptics, feedbackModel: feedbackModel)
            logger.error("Failed to load summary for brand. Error: \(error) (\(#file):\(#line))")
        }

        if let initialScrollPosition, let proxy {
            try? await Task.sleep(for: .milliseconds(100))
            proxy.scrollTo(initialScrollPosition, anchor: .top)
        }
    }

    private func toggleLike() async {
        if isLikedByCurrentUser {
            do {
                try await repository.brand.unlikeBrand(id: id)
                feedbackModel.trigger(.notification(.success))
                withAnimation {
                    isLikedByCurrentUser = false
                }
            } catch {
                guard !error.isCancelled else { return }
                logger.error("Unliking brand failed. Error: \(error) (\(#file):\(#line))")
            }
        } else {
            do {
                try await repository.brand.likeBrand(id: id)
                feedbackModel.trigger(.notification(.success))
                withAnimation {
                    isLikedByCurrentUser = true
                }
            } catch {
                guard !error.isCancelled else { return }
                logger.error("Liking a brand failed. Error: \(error) (\(#file):\(#line))")
            }
        }
    }
}

private struct ProductsByCategory: Identifiable {
    var id: Models.Category.Id {
        category.id
    }

    let category: Models.Category.Saved
    var products: [Product.Joined]
}

private enum GroupProductsBy: String, CaseIterable {
    case subBrand, category
}

struct SubBrandSectionHeaderView: View {
    @Environment(Router.self) private var router
    @Environment(ProfileModel.self) private var profileModel
    let brand: Brand.JoinedSubBrandsCompany
    let subBrand: SubBrand.JoinedProductJoined

    var body: some View {
        HStack {
            if let name = subBrand.name {
                Text(name)
            }
            Spacer()
            Menu {
                if profileModel.hasPermission(.canCreateProducts) {
                    RouterLink(
                        "brand.createProduct.label",
                        systemImage: "plus",
                        open: .sheet(.product(.addToSubBrand(brand, subBrand, onCreate: { newProduct in
                            router.open(.screen(.product(newProduct.id), removeLast: true))
                        })))
                    )
                }
                Divider()
                RouterLink("labels.editSuggestion", systemImage: "pencil", open: .sheet(.subBrandEditSuggestion(brand: .init(brand: brand), subBrand: .init(brand: brand, subBrand: .init(subBrand: subBrand)), onSuccess: {
                    router.open(.toast(.success("brand.editSuggestion.submitted")))
                })))
                ReportButton(entity: .subBrand(.init(brand: brand, subBrand: .init(subBrand: subBrand))))
                Divider()
                AdminRouterLink(open: .sheet(.subBrandAdmin(id: subBrand.id)))
            } label: {
                Label("labels.menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
                    .frame(width: 24, height: 24)
            }
        }
    }
}
