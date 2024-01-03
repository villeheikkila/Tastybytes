import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct VerificationScreen: View {
    enum VerificationType: String, CaseIterable, Identifiable {
        var id: Self { self }

        case products, brands, subBrands, companies

        var label: String {
            switch self {
            case .products:
                "Products"
            case .brands:
                "Brands"
            case .companies:
                "Companies"
            case .subBrands:
                "Sub-brands"
            }
        }
    }

    private let logger = Logger(category: "ProductVerificationScreen")
    @Environment(\.repository) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var products = [Product.Joined]()
    @State private var companies = [Company]()
    @State private var brands = [Brand.JoinedSubBrandsProductsCompany]()
    @State private var subBrands = [SubBrand.JoinedBrand]()
    @State private var verificationType: VerificationType = .products
    @State private var alertError: AlertError?
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
        .alertError($alertError)
        .navigationBarTitle("Unverified \(verificationType.label)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            toolbarContent
        }
        .task(id: verificationType) {
            await loadData()
        }
        #if !targetEnvironment(macCatalyst)
        .refreshable {
            await loadData(refresh: true)
        }
        #endif
    }

    private var unverifiedCompanies: some View {
        ForEach(companies) { company in
            RouterLink(company.name, screen: .company(company))
                .swipeActions {
                    ProgressButton("Verify", systemImage: "checkmark", action: { await verifyCompany(company) })
                        .tint(.green)
                }
        }
    }

    @MainActor
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
                ProgressButton("Verify", systemImage: "checkmark", action: { await verifySubBrand(subBrand) })
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
                ProgressButton("Verify", systemImage: "checkmark", action: { await verifyBrand(brand) }).tint(.green)
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
                        if let createdAt = product.createdAt {
                            Text(createdAt.customFormat(.relativeTime)).font(.caption).bold()
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
                        ProgressButton("Verify", systemImage: "checkmark", action: { await verifyProduct(product) })
                            .tint(.green)
                        RouterLink("Edit", systemImage: "pencil", sheet: .productEdit(product: product, onEdit: {
                            await loadData(refresh: true)
                        })).tint(.yellow)
                        Button("Delete", systemImage: "trash", role: .destructive, action: { deleteProduct = product })
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
            withAnimation {
                brands.remove(object: brand)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to verify brand \(brand.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    func verifySubBrand(_ subBrand: SubBrand.JoinedBrand) async {
        switch await repository.subBrand.verification(id: subBrand.id, isVerified: true) {
        case .success:
            withAnimation {
                subBrands.remove(object: subBrand)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to verify brand \(subBrand.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    func verifyCompany(_ company: Company) async {
        switch await repository.company.verification(id: company.id, isVerified: true) {
        case .success:
            withAnimation {
                companies.remove(object: company)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to verify company. Error: \(error) (\(#file):\(#line))")
        }
    }

    func verifyProduct(_ product: Product.Joined) async {
        switch await repository.product.verification(id: product.id, isVerified: true) {
        case .success:
            withAnimation {
                products.remove(object: product)
            }
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
            await loadData(refresh: true)
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete product. Error: \(error) (\(#file):\(#line))")
        }
    }

    func loadData(refresh: Bool = false) async {
        switch verificationType {
        case .products:
            if refresh || products.isEmpty {
                switch await repository.product.getUnverified() {
                case let .success(products):
                    withAnimation {
                        self.products = products
                    }
                    if refresh {
                        feedbackEnvironmentModel.trigger(.notification(.success))
                    }
                case let .failure(error):
                    guard !error.isCancelled else { return }
                    alertError = .init()
                    logger.error("Loading unverfied products failed. Error: \(error) (\(#file):\(#line))")
                }
            }
        case .companies:
            if refresh || companies.isEmpty {
                switch await repository.company.getUnverified() {
                case let .success(companies):
                    withAnimation {
                        self.companies = companies
                    }
                case let .failure(error):
                    guard !error.isCancelled else { return }
                    alertError = .init()
                    logger.error("Loading unverfied companies failed. Error: \(error) (\(#file):\(#line))")
                }
            }
        case .brands:
            if refresh || brands.isEmpty {
                switch await repository.brand.getUnverified() {
                case let .success(brands):
                    withAnimation {
                        self.brands = brands
                    }
                case let .failure(error):
                    guard !error.isCancelled else { return }
                    alertError = .init()
                    logger.error("Loading unverfied brands failed. Error: \(error) (\(#file):\(#line))")
                }
            }
        case .subBrands:
            if refresh || subBrands.isEmpty {
                switch await repository.subBrand.getUnverified() {
                case let .success(subBrands):
                    withAnimation {
                        self.subBrands = subBrands
                    }
                case let .failure(error):
                    guard !error.isCancelled else { return }
                    alertError = .init()
                    logger.error("Loading unverfied sub-brands failed. Error: \(error) (\(#file):\(#line))")
                }
            }
        }
    }
}
