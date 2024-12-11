import Components

import Extensions
import Logging
import Models
import PhotosUI
import Repositories
import SwiftUI

struct BrandAdminSheet: View {
    typealias OnUpdateCallback = (_ updatedBrand: Brand.Detailed) async -> Void
    typealias OnDeleteCallback = (_ updatedBrand: Brand.Id) async -> Void

    enum Open {
        case report(Report.Id)
        case editSuggestions(Brand.EditSuggestion.Id)
    }

    private let logger = Logger(label: "BrandAdminSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileModel.self) private var profileModel
    @Environment(\.dismiss) private var dismiss
    @State private var state: ScreenState = .loading
    @State private var name: String = ""
    @State private var brandOwner: Company.Saved?
    @State private var brand = Brand.Detailed()
    @State private var newCompanyName = ""

    let id: Brand.Id
    let open: Open?
    let onUpdate: OnUpdateCallback
    let onDelete: OnDeleteCallback

    private var isValidNameUpdate: Bool {
        name.isValidLength(.normal(allowEmpty: false)) && brand.name != name
    }

    private var isValidBrandOwnerUpdate: Bool {
        if let brandOwner {
            brandOwner.id == brand.brandOwner.id
        } else {
            false
        }
    }

    private var isValidUpdate: Bool {
        isValidNameUpdate || isValidBrandOwnerUpdate
    }

    var body: some View {
        Form {
            if state.isPopulated {
                content
            }
        }
        .scrollContentBackground(.hidden)
        .animation(.default, value: brand)
        .navigationTitle("brand.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            ScreenStateOverlayView(state: state) {
                await initialize()
            }
        }
        .toolbar {
            toolbarContent
        }
        .initialTask {
            await initialize()
        }
    }

    @ViewBuilder private var content: some View {
        Section("brand.admin.section.brand") {
            RouterLink(open: .screen(.brand(brand.id))) {
                BrandView(brand: brand)
            }
        }
        .customListRowBackground()
        ModificationInfoView(modificationInfo: brand)
        Section("admin.section.details") {
            LabeledTextFieldView(title: "brand.admin.changeName.label", text: $name)
            LabeledContent("brand.admin.changeBrandOwner.label") {
                RouterLink(brandOwner?.name ?? "", open: .sheet(.companyPicker(onSelect: { company in
                    brandOwner = company
                })))
            }
        }
        .customListRowBackground()
        EditLogoSectionView(logos: brand.logos, onAdd: addLogo, onRemove: removeLogo)
        Section("labels.info") {
            LabeledIdView(id: brand.id.rawValue.formatted())
            LabeledContent("brandOwner.label") {
                RouterLink(
                    brand.brandOwner.name,
                    open: .sheet(
                        .companyAdmin(
                            id: brand.brandOwner.id,
                            onUpdate: { company in
                                brand = brand.copyWith(brandOwner: .init(company: company))
                                await onUpdate(brand)
                            }
                        )
                    )
                )
            }
            RouterLink(
                "brand.admin.subBrands.label",
                count: brand.subBrands.count,
                open: .screen(
                    .subBrandListAdmin(
                        brand: .init(brand: brand),
                        subBrands: $brand.map(getter: { _ in brand.subBrands }, setter: { subBrands in
                            brand.copyWith(subBrands: subBrands)
                        })
                    )
                )
            )
            LabeledContent("brand.admin.products.count", value: brand.productCount.formatted())
            VerificationAdminToggleView(isVerified: brand.isVerified, action: verifyBrand)
        }
        .customListRowBackground()
        Section {
            RouterLink(
                "admin.section.reports.title",
                systemImage: "exclamationmark.bubble",
                badge: brand.reports.count,
                open: .screen(
                    .reports(reports: $brand.map(getter: { location in
                        location.reports
                    }, setter: { reports in
                        brand.copyWith(reports: reports)
                    }))
                )
            )
            RouterLink("admin.section.editSuggestions.title", systemImage: "square.and.pencil", badge: brand.editSuggestions.unresolvedCount, open: .screen(.brandEditSuggestionAdmin(brand: $brand)))
        }
        .customListRowBackground()
        Section {
            ConfirmedDeleteButtonView(
                presenting: brand,
                action: deleteBrand,
                description: "brand.delete.disclaimer",
                label: "brand.delete.label \(brand.name)",
                isDisabled: brand.isVerified
            )
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItem(placement: .primaryAction) {
            AsyncButton("labels.edit") {
                await editBrand(brand: brand)
            }
            .disabled(!isValidUpdate)
        }
    }

    private func initialize() async {
        do {
            let brand = try await repository.brand.getDetailed(id: id)
            self.brand = brand
            brandOwner = brand.brandOwner
            name = brand.name
            state = .populated
            if let open {
                switch open {
                case let .report(id):
                    router.open(.screen(
                        .reports(reports: $brand.map(getter: { location in
                            location.reports
                        }, setter: { reports in
                            brand.copyWith(reports: reports)
                        }), initialReport: id)))
                case let .editSuggestions(id):
                    router.open(.screen(.brandEditSuggestionAdmin(brand: $brand, initialEditSuggestion: id)))
                }
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error(error)
            logger.error("Failed to load detailed brand info. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func verifyBrand(isVerified: Bool) async {
        do {
            try await repository.brand.verification(id: brand.id, isVerified: isVerified)
            brand = brand.copyWith(isVerified: isVerified)
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to verify brand'. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func editBrand(brand: Brand.Detailed) async {
        do {
            let brand = try await repository.brand.update(
                updateRequest: .init(
                    id: id,
                    name: isValidNameUpdate ? name : brand.name,
                    brandOwnerId: isValidBrandOwnerUpdate ? brandOwner?.id : nil
                )
            )
            router.open(.toast(.success("brand.edit.success.toast")))
            self.brand = brand
            await onUpdate(brand)
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to edit brand. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func addLogo(logo: Logo.Saved) async {
        do {
            try await repository.brand.addLogo(id: id, logoId: logo.id)
            withAnimation {
                brand = brand.copyWith(logos: brand.logos + [logo])
            }
            await onUpdate(brand)
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Uploading of a brand logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func removeLogo(logo: Logo.Saved) async {
        do {
            try await repository.brand.removeLogo(id: id, logoId: logo.id)
            withAnimation {
                brand = brand.copyWith(logos: brand.logos.removing(logo))
            }
            await onUpdate(brand)
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteBrand(_ brand: Brand.Detailed) async {
        do {
            try await repository.brand.delete(id: brand.id)
            await onDelete(brand.id)
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete brand. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct SubBrandListAdminScreen: View {
    let brand: Brand.Saved
    @Binding var subBrands: [SubBrand.JoinedProduct]

    var body: some View {
        List(subBrands) { subBrand in
            RouterLink(open: .sheet(.subBrandAdmin(id: subBrand.id, onUpdate: { subBrand in
                subBrands = subBrands.replacingWithId(subBrand.id, with: .init(subBrand: subBrand))
            }, onDelete: { id in
                subBrands = subBrands.removingWithId(id)
            }))) {
                SubBrandView(brand: brand, subBrand: subBrand)
            }
        }
        .listStyle(.plain)
        .navigationTitle("subBrandListAdmin.navigationTitle \(brand.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
