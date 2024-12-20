import Extensions
import Logging
import Models
import Repositories
import SwiftUI

typealias OnSnack = (Snack) -> Void

@MainActor
@Observable
final class AdminModel {
    private let logger = Logger(label: "AdminModel")

    public var events = [AdminEvent.Joined]()
    public var unverified = [VerifiableEntity]()
    public var editSuggestions = [EditSuggestion]()
    public var reports = [Report.Joined]()
    public var logos = [Logo.Saved]()

    public var notificationCount: Int {
        events.count + unverified.count + editSuggestions.count + reports.count
    }

    public var roles = [Role.Joined]()

    private let repository: Repository
    private let onSnack: OnSnack

    init(repository: Repository, onSnack: @escaping OnSnack) {
        self.repository = repository
        self.onSnack = onSnack
    }

    public func initialize() async {
        async let logos = repository.logo.getAll()
        async let events = repository.admin.getAdminEventFeed()
        async let roles = repository.role.getRoles()
        async let unverified: Void = loadUnverifiedEntities()
        async let editSuggestions: Void = loadEditSuggestions()
        async let reports: Void = loadReports()
        do {
            let (logos, events, roles, _, _, _) = try await (logos, events, roles, unverified, editSuggestions, reports)
            self.logos = logos
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
            reports = try await repository.report.getAll()
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

    // logos
    public func loadLogos() async {
        do {
            logos = try await repository.logo.getAll()
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to load logos")))
            logger.error("Loading logos failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func createLogo(image: UIImage, label: String, onSuccess: () -> Void) async {
        guard let data = image.pngData() else { return }
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        guard let blurHash = image.resize(to: 32)?.blurHash(numberOfComponents: (4, 3)) else { return }
        do {
            let logo = try await repository.logo.insert(data: data, width: width, height: height, blurHash: blurHash, label: label)
            logos = logos + [logo]
            onSuccess()
        } catch {
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to create logo")))
            logger.error("Creating logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func updateLogo(logo: Logo.Saved, label: String) async {
        do {
            let updated = try await repository.logo.update(id: logo.id, label: label)
            logos = logos.replacingWithId(updated.id, with: updated)
        } catch {
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to update logo")))
            logger.error("Failed to update logo \(logo.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteLogo(_ logo: Logo.Saved) async {
        do {
            try await repository.logo.delete(id: logo.id)
            logos = logos.removing(logo)
        } catch {
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to delete logo")))
            logger.error("Failed to delete logo \(logo.id). Error: \(error) (\(#file):\(#line))")
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
