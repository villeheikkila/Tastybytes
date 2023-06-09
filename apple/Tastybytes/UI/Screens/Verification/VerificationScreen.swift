import OSLog
import SwiftUI

struct VerificationScreen: View {
    enum VerificationType: String, CaseIterable, Identifiable {
        var id: Self { self }

        case products, brands, subBrands, companies

        var label: String {
            switch self {
            case .products:
                return "Products"
            case .brands:
                return "Brands"
            case .companies:
                return "Companies"
            case .subBrands:
                return "Sub-brands"
            }
        }
    }

    private let logger = Logger(category: "ProductVerificationScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackManager.self) private var feedbackManager
    @State private var products = [Product.Joined]()
    @State private var companies = [Company]()
    @State private var brands = [Brand.JoinedSubBrandsProductsCompany]()
    @State private var subBrands = [SubBrand.JoinedBrand]()
    @State private var verificationType: VerificationType = .products
    @State private var deleteProduct: Product.Joined? {
        didSet {
            showDeleteProductConfirmationDialog = true
        }
    }

    @State private var showDeleteProductConfirmationDialog = false

    var body: some View {
        List {
            switch verificationType {
            case .products:
                unverifiedProducts
            case .companies:
                unverifiedCompanies
            case .brands:
                unverifiedBrands
            case .subBrands:
                unverifiedSubBrands
            }
        }
        .listStyle(.plain)
        .confirmationDialog("Are you sure you want to delete the product and all of its check-ins?",
                            isPresented: $showDeleteProductConfirmationDialog,
                            titleVisibility: .visible,
                            presenting: deleteProduct)
        { presenting in
            ProgressButton(
                "Delete \(presenting.getDisplayName(.fullName))",
                role: .destructive,
                action: { await deleteProduct(presenting) }
            )
        }
        .navigationBarTitle("Unverified \(verificationType.label)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            toolbarContent
        }
        .onChange(of: verificationType) {
            Task {
                await loadData()
            }
        }
        #if !targetEnvironment(macCatalyst)
        .refreshable {
            await loadData(refresh: true)
        }
        #endif
        .task {
            await loadData()
        }
    }

    private var unverifiedCompanies: some View {
        ForEach(companies) { company in
            RouterLink(company.name, screen: .company(company))
                .swipeActions {
                    ProgressButton("Verify", systemSymbol: .checkmark, action: { await verifyCompany(company) })
                        .tint(.green)
                }
        }
    }

    private var unverifiedSubBrands: some View {
        ForEach(subBrands) { subBrand in
            HStack {
                Text("\(subBrand.brand.brandOwner.name): \(subBrand.brand.name): \(subBrand.name ?? "-")")
                Spacer()
            }
            .onTapGesture {
                router.fetchAndNavigateTo(repository, .brand(id: subBrand.brand.id))
            }
            .accessibilityAddTraits(.isButton)
            .swipeActions {
                ProgressButton("Verify", systemSymbol: .checkmark, action: { await verifySubBrand(subBrand) })
                    .tint(.green)
            }
        }
    }

    private var unverifiedBrands: some View {
        ForEach(brands) { brand in
            RouterLink(screen: .brand(brand)) {
                HStack {
                    Text("\(brand.brandOwner.name): \(brand.name)")
                    Spacer()
                    Text("(\(brand.getNumberOfProducts()))")
                }
            }
            .swipeActions {
                ProgressButton("Verify", systemSymbol: .checkmark, action: { await verifyBrand(brand) }).tint(.green)
            }
        }
    }

    private var unverifiedProducts: some View {
        ForEach(products) { product in
            VStack {
                if let createdBy = product.createdBy {
                    HStack {
                        AvatarView(avatarUrl: createdBy.avatarUrl, size: 16, id: createdBy.id)
                        Text(createdBy.preferredName).font(.caption).bold()
                        Spacer()
                        if let createdAt = product.createdAt, let date = Date(timestamptzString: createdAt) {
                            Text(date.customFormat(.relativeTime)).font(.caption).bold()
                        }
                    }
                }
                ProductItemView(product: product)
                    .contentShape(Rectangle())
                    .accessibilityAddTraits(.isLink)
                    .onTapGesture {
                        router.navigate(screen: .product(product))
                    }
                    .swipeActions {
                        ProgressButton("Verify", systemSymbol: .checkmark, action: { await verifyProduct(product) })
                            .tint(.green)
                        RouterLink("Edit", systemSymbol: .pencil, sheet: .productEdit(product: product, onEdit: {
                            await loadData(refresh: true)
                        })).tint(.yellow)
                        Button("Delete", systemSymbol: .trash, role: .destructive, action: { deleteProduct = product })
                    }
            }
        }
    }

    private var toolbarContent: some ToolbarContent {
        ToolbarTitleMenu {
            ForEach(VerificationType.allCases) { type in
                Button {
                    verificationType = type
                } label: {
                    Text("Unverified \(type.label)")
                }
            }
        }
    }

    func verifyBrand(_ brand: Brand.JoinedSubBrandsProductsCompany) async {
        switch await repository.brand.verification(id: brand.id, isVerified: true) {
        case .success:
            await MainActor.run {
                withAnimation {
                    brands.remove(object: brand)
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to verify brand \(brand.id). error: \(error)")
        }
    }

    func verifySubBrand(_ subBrand: SubBrand.JoinedBrand) async {
        switch await repository.subBrand.verification(id: subBrand.id, isVerified: true) {
        case .success:
            await MainActor.run {
                withAnimation {
                    subBrands.remove(object: subBrand)
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to verify brand \(subBrand.id). error: \(error)")
        }
    }

    func verifyCompany(_ company: Company) async {
        switch await repository.company.verification(id: company.id, isVerified: true) {
        case .success:
            await MainActor.run {
                withAnimation {
                    companies.remove(object: company)
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to verify company. error: \(error)")
        }
    }

    func verifyProduct(_ product: Product.Joined) async {
        switch await repository.product.verification(id: product.id, isVerified: true) {
        case .success:
            await MainActor.run {
                withAnimation {
                    products.remove(object: product)
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to verify product. error: \(error)")
        }
    }

    func deleteProduct(_ product: Product.Joined) async {
        switch await repository.product.delete(id: product.id) {
        case .success:
            feedbackManager.trigger(.notification(.success))
            await loadData(refresh: true)
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to delete product. error: \(error)")
        }
    }

    func loadData(refresh: Bool = false) async {
        switch verificationType {
        case .products:
            if refresh || products.isEmpty {
                switch await repository.product.getUnverified() {
                case let .success(products):
                    await MainActor.run {
                        withAnimation {
                            self.products = products
                        }
                    }
                    if refresh {
                        feedbackManager.trigger(.notification(.success))
                    }
                case let .failure(error):
                    guard !error.localizedDescription.contains("cancelled") else { return }
                    feedbackManager.toggle(.error(.unexpected))
                    logger.error("loading unverfied products failed. error: \(error)")
                }
            }
        case .companies:
            if refresh || companies.isEmpty {
                switch await repository.company.getUnverified() {
                case let .success(companies):
                    await MainActor.run {
                        withAnimation {
                            self.companies = companies
                        }
                    }
                case let .failure(error):
                    guard !error.localizedDescription.contains("cancelled") else { return }
                    feedbackManager.toggle(.error(.unexpected))
                    logger.error("loading unverfied companies failed. error: \(error)")
                }
            }
        case .brands:
            if refresh || brands.isEmpty {
                switch await repository.brand.getUnverified() {
                case let .success(brands):
                    await MainActor.run {
                        withAnimation {
                            self.brands = brands
                        }
                    }
                case let .failure(error):
                    guard !error.localizedDescription.contains("cancelled") else { return }
                    feedbackManager.toggle(.error(.unexpected))
                    logger.error("loading unverfied brands failed. error: \(error)")
                }
            }
        case .subBrands:
            if refresh || subBrands.isEmpty {
                switch await repository.subBrand.getUnverified() {
                case let .success(subBrands):
                    await MainActor.run {
                        withAnimation {
                            self.subBrands = subBrands
                        }
                    }
                case let .failure(error):
                    guard !error.localizedDescription.contains("cancelled") else { return }
                    feedbackManager.toggle(.error(.unexpected))
                    logger.error("loading unverfied sub-brands failed. error: \(error)")
                }
            }
        }
    }
}
