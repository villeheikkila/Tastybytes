import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
@Observable
public final class AdminEnvironmentModel {
    private let logger = Logger(category: "AdminEnvironmentModel")

    public var events = [AdminEvent]()
    public var unresolvedEventCount: Int {
        events.count
    }

    public var unverifiedEntities = [VerifiableEntity]()

    public var roles = [Role]()

    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public func initialize() async {
        async let events = repository.admin.getAdminEventFeed()
        async let roles = repository.role.getRoles()
        do {
            let (events, roles) = try await (events, roles)
            self.events = events
            self.roles = roles
        } catch {
            logger.error("Failed to initialize admin environment model")
        }
    }

    public func loadAdminEventFeed() async {
        do {
            events = try await repository.admin.getAdminEventFeed()
        } catch {
            logger.error("Failed to load admin event feed")
        }
    }

    private func loadRoles() async {
        do {
            roles = try await repository.role.getRoles()
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to load roles. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func markAsReviewed(_ event: AdminEvent) async {
        do {
            try await repository.admin.markAdminEventAsReviewed(event: event)
            events = events.removing(event)
        } catch {
            logger.error("Failed to mark admin event as reviewed")
        }
    }

    // Verification
    public func loadUnverifiedEntities(refresh _: Bool = false) async {
        do {
            async let companiesPromise = repository.company.getUnverified()
            async let productsPromise = repository.product.getUnverified()
            async let brandsPromise = repository.brand.getUnverified()
            async let subBrandsPromise = repository.subBrand.getUnverified()

            let (unverifiedCompanies, unverifiedProducts, unverifiedBrands, unverifiedSubBrands) = try await (
                companiesPromise,
                productsPromise,
                brandsPromise,
                subBrandsPromise
            )

            let companies: [VerifiableEntity] = unverifiedCompanies.map { .company($0) }
            let products: [VerifiableEntity] = unverifiedProducts.map { .product($0) }
            let brands: [VerifiableEntity] = unverifiedBrands.map { .brand($0) }
            let subBrands: [VerifiableEntity] = unverifiedSubBrands.map { .subBrand($0) }

            unverifiedEntities = companies + products + brands + subBrands
        } catch {
            logger.error("Failed to load unverified entities. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func verifyEntity(_ entity: VerifiableEntity) async {
        do {
            switch entity {
            case let .brand(brand):
                try await repository.brand.verification(id: brand.id, isVerified: true)
            case let .company(company):
                try await repository.company.verification(id: company.id, isVerified: true)
            case let .product(product):
                try await repository.product.verification(id: product.id, isVerified: true)
            case let .subBrand(subBrand):
                try await repository.subBrand.verification(id: subBrand.id, isVerified: true)
            }
            unverifiedEntities = unverifiedEntities.removing(entity)
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to verify product. Error: \(error) (\(#file):\(#line))")
        }
    }
}
