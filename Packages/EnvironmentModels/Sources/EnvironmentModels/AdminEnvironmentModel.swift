import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
@Observable
public final class AdminEnvironmentModel {
    private let logger = Logger(category: "AdminEnvironmentModel")

    public var events = [AdminEvent.Joined]()
    public var unverified = [VerifiableEntity]()
    public var editSuggestions = [EditSuggestion]()
    public var reports = [Report.Joined]()

    public var notificationCount: Int {
        events.count + unverified.count + editSuggestions.count + reports.count
    }

    public var roles = [Role.Joined]()

    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public func initialize() async {
        async let events = repository.admin.getAdminEventFeed()
        async let roles = repository.role.getRoles()
        async let unverified: Void = loadUnverifiedEntities()
        async let editSuggestions: Void = loadEditSuggestions()
        async let reports: Void = loadReports()
        do {
            let (events, roles, _, _, _) = try await (events, roles, unverified, editSuggestions, reports)
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

    public func markAsReviewed(_ event: AdminEvent.Joined) async {
        do {
            try await repository.admin.markAdminEventAsReviewed(id: event.id)
            events = events.removing(event)
        } catch {
            logger.error("Failed to mark admin event as reviewed")
        }
    }

    // Verification
    public func loadUnverifiedEntities() async {
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

            unverified = companies + products + brands + subBrands
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
            unverified = unverified.removing(entity)
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to verify product. Error: \(error) (\(#file):\(#line))")
        }
    }

    // Edit suggestions
    public func deleteEditSuggestion(_ editSuggestion: EditSuggestion) async {
        do {
            try await editSuggestion.deleteSuggestion(repository: repository, editSuggestion)
            editSuggestions = editSuggestions.removing(editSuggestion)
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to delete an edit suggestions")
        }
    }

    public func loadEditSuggestions() async {
        do {
            async let companyEditSuggestionsPromise = repository.company.getEditSuggestions()
            async let productEditSuggestionsPromise = repository.product.getEditSuggestions()
            async let brandEditSuggestionsPromise = repository.brand.getEditSuggestions()
            async let subBrandEditSuggestionsPromise = repository.subBrand.getEditSuggestions()

            let (companyEditSuggestions, productEditSuggestions, brandEditSuggestions, subBrandEditSuggestions) = try await (
                companyEditSuggestionsPromise,
                productEditSuggestionsPromise,
                brandEditSuggestionsPromise,
                subBrandEditSuggestionsPromise
            )

            let companies: [EditSuggestion] = companyEditSuggestions.map { .company($0) }
            let products: [EditSuggestion] = productEditSuggestions.map { .product($0) }
            let brands: [EditSuggestion] = brandEditSuggestions.map { .brand($0) }
            let subBrands: [EditSuggestion] = subBrandEditSuggestions.map { .subBrand($0) }

            editSuggestions = companies + products + brands + subBrands
        } catch {
            logger.error("Failed to load edit suggestion entities. Error: \(error) (\(#file):\(#line))")
        }
    }

    // Reports
    public func loadReports() async {
        do {
            let reports = try await repository.report.getAll(nil)
            self.reports = reports
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Loading reports failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteReport(_ report: Report.Joined) async {
        do {
            try await repository.report.delete(id: report.id)
            reports = reports.removing(report)
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to delete report \(report.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    public func resolveReport(_ report: Report.Joined) async {
        do {
            try await repository.report.resolve(id: report.id)
            reports = reports.removing(report)
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to resolve report \(report.id). Error: \(error) (\(#file):\(#line))")
        }
    }
}

public extension EditSuggestion {
    func deleteSuggestion(repository: Repository, _ editSuggestion: Self) async throws {
        switch self {
        case let .product(editSuggestion):
            try await repository.product.deleteEditSuggestion(editSuggestion: editSuggestion)
        case let .company(editSuggestion):
            try await repository.company.deleteEditSuggestion(editSuggestion: editSuggestion)
        case let .brand(editSuggestion):
            try await repository.brand.deleteEditSuggestion(editSuggestion: editSuggestion)
        case let .subBrand(editSuggestion):
            try await repository.subBrand.deleteEditSuggestion(editSuggestion: editSuggestion)
        }
    }
}
