import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct VerificationScreen: View {
    enum VerificationType: String, CaseIterable, Identifiable {
        var id: Self { self }

        case products, brands, subBrands, companies

        var label: LocalizedStringKey {
            switch self {
            case .products:
                "product.title"
            case .brands:
                "brand.title"
            case .companies:
                "company.title"
            case .subBrands:
                "subBrand.title"
            }
        }
    }

    private let logger = Logger(category: "ProductVerificationScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var products = [Product.Joined]()
    @State private var companies = [Company]()
    @State private var brands = [Brand.JoinedSubBrandsProductsCompany]()
    @State private var subBrands = [SubBrand.JoinedBrand]()
    @State private var verificationType: VerificationType = .products

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
        .refreshable {
            await loadData(refresh: true)
        }
        .navigationBarTitle(Text("labels.unverified") + Text(verificationType.label))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task(id: verificationType) {
            await loadData()
        }
    }

    private var unverifiedCompanies: some View {
        ForEach(companies) { company in
            RouterLink(company.name, open: .screen(.company(company)))
                .swipeActions {
                    AsyncButton("labels.verify", systemImage: "checkmark", action: { await verifyCompany(company) })
                        .tint(.green)
                }
        }
    }

    private var unverifiedSubBrands: some View {
        ForEach(subBrands) { subBrand in
            RouterLink(open: .navigatablePath(.brand(id: subBrand.brand.id))) {
                HStack {
                    Text("\(subBrand.brand.brandOwner.name): \(subBrand.brand.name): \(subBrand.name ?? "-")")
                    Spacer()
                }
            }
            .swipeActions {
                AsyncButton("labels.verify", systemImage: "checkmark", action: { await verifySubBrand(subBrand) })
                    .tint(.green)
            }
        }
    }

    private var unverifiedBrands: some View {
        ForEach(brands) { brand in
            RouterLink(open: .screen(.brand(brand))) {
                HStack {
                    Text("\(brand.brandOwner.name): \(brand.name)")
                    Spacer()
                    Text(brand.productCount.formatted())
                }
            }
            .swipeActions {
                AsyncButton("labels.verify", systemImage: "checkmark", action: { await verifyBrand(brand) }).tint(.green)
            }
        }
    }

    private var unverifiedProducts: some View {
        ForEach(products) { product in
            VerificationScreenProductRowView(product: product) {
                await verifyProduct(product)
            } onEdit: { edited in
                products.replace(product, with: edited)
            } onDelete: {
                await deleteProduct(product)
            }
        }
    }

    private var toolbarContent: some ToolbarContent {
        ToolbarTitleMenu {
            ForEach(VerificationType.allCases) { type in
                Button {
                    verificationType = type
                } label: {
                    Text("labels.unverified") + Text(type.label)
                }
            }
        }
    }

    private func verifyBrand(_ brand: Brand.JoinedSubBrandsProductsCompany) async {
        do {
            try await repository.brand.verification(id: brand.id, isVerified: true)
            withAnimation {
                brands.remove(object: brand)
            }
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to verify brand \(brand.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    private func verifySubBrand(_ subBrand: SubBrand.JoinedBrand) async {
        do {
            try await repository.subBrand.verification(id: subBrand.id, isVerified: true)
            withAnimation {
                subBrands.remove(object: subBrand)
            }
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to verify brand \(subBrand.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    private func verifyCompany(_ company: Company) async {
        do {
            try await repository.company.verification(id: company.id, isVerified: true)
            withAnimation {
                companies.remove(object: company)
            }
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to verify company. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func verifyProduct(_ product: Product.Joined) async {
        do {
            try await repository.product.verification(id: product.id, isVerified: true)
            withAnimation {
                products.remove(object: product)
            }
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to verify product. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteProduct(_ product: Product.Joined) async {
        do {
            try await repository.product.delete(id: product.id)
            feedbackEnvironmentModel.trigger(.notification(.success))
            withAnimation {
                products = products.removing(product)
            }
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete product. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func loadData(refresh: Bool = false) async {
        switch verificationType {
        case .products:
            if refresh || products.isEmpty {
                do { let products = try await repository.product.getUnverified()
                    withAnimation {
                        self.products = products
                    }
                    if refresh {
                        feedbackEnvironmentModel.trigger(.notification(.success))
                    }
                } catch {
                    guard !error.isCancelled else { return }
                    router.open(.alert(.init()))
                    logger.error("Loading unverfied products failed. Error: \(error) (\(#file):\(#line))")
                }
            }
        case .companies:
            if refresh || companies.isEmpty {
                do { let companies = try await repository.company.getUnverified()
                    withAnimation {
                        self.companies = companies
                    }
                } catch {
                    guard !error.isCancelled else { return }
                    router.open(.alert(.init()))
                    logger.error("Loading unverfied companies failed. Error: \(error) (\(#file):\(#line))")
                }
            }
        case .brands:
            if refresh || brands.isEmpty {
                do {
                    let brands = try await repository.brand.getUnverified()
                    withAnimation {
                        self.brands = brands
                    }
                } catch {
                    guard !error.isCancelled else { return }
                    router.open(.alert(.init()))
                    logger.error("Loading unverfied brands failed. Error: \(error) (\(#file):\(#line))")
                }
            }
        case .subBrands:
            if refresh || subBrands.isEmpty {
                do {
                    let subBrands = try await repository.subBrand.getUnverified()
                    withAnimation {
                        self.subBrands = subBrands
                    }
                } catch {
                    guard !error.isCancelled else { return }
                    router.open(.alert(.init()))
                    logger.error("Loading unverfied sub-brands failed. Error: \(error) (\(#file):\(#line))")
                }
            }
        }
    }
}

struct VerificationScreenProductRowView: View {
    @State private var showDeleteProductConfirmationDialog = false

    let product: Product.Joined
    let onVerify: () async -> Void
    let onEdit: (_ product: Product.Joined) async -> Void
    let onDelete: () async -> Void

    var body: some View {
        RouterLink(open: .screen(.product(product))) {
            VStack {
//                if let createdBy = product?.createdBy {
//                    HStack {
//                        Avatar(profile: createdBy)
//                            .avatarSize(.small)
//                        Text(createdBy.preferredName).font(.caption).bold()
//                        Spacer()
//                        if let createdAt = product.createdAt {
//                            Text(createdAt.formatted(.customRelativetime)).font(.caption).bold()
//                        }
//                    }
//                }
                ProductEntityView(product: product)
            }
        }
        .swipeActions {
            AsyncButton("labels.verify", systemImage: "checkmark", action: onVerify)
                .tint(.green)
            RouterLink("labels.edit", systemImage: "pencil", open: .sheet(.product(.edit(product, onEdit: onEdit)))).tint(.yellow)
            AsyncButton("labels.delete", systemImage: "trash", action: {
                showDeleteProductConfirmationDialog = true
            })
            .tint(.red)
        }
        .confirmationDialog("product.delete.confirmation.title",
                            isPresented: $showDeleteProductConfirmationDialog,
                            titleVisibility: .visible,
                            presenting: product)
        { presenting in
            AsyncButton(
                "product.delete.confirmation.label \(presenting.formatted(.fullName))",
                role: .destructive,
                action: onDelete
            )
        }
    }
}
