import Components

import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct CompanyAdminSheet: View {
    typealias OnUpdateCallback = (Company.Detailed) async -> Void
    typealias OnDeleteCallback = (Company.Id) -> Void

    enum Open {
        case report(Report.Id)
        case editSuggestions(Company.EditSuggestion.Id)
    }

    private let logger = Logger(category: "CompanyAdminSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var state: ScreenState = .loading
    @State private var company = Company.Detailed()
    @State private var name = ""

    @State private var id: Company.Id
    @State private var open: Open?
    private let onUpdate: OnUpdateCallback
    private let onDelete: OnDeleteCallback

    init(
        id: Company.Id,
        open: Open? = nil,
        onUpdate: @escaping OnUpdateCallback,
        onDelete: @escaping OnDeleteCallback
    ) {
        self.id = id
        self.open = open
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }

    private var isValidNameUpdate: Bool {
        name.isValidLength(.normal(allowEmpty: false)) && name != company.name
    }

    var body: some View {
        Form {
            if state.isPopulated {
                content
            }
        }
        .scrollContentBackground(.hidden)
        .animation(.default, value: company)
        .overlay {
            ScreenStateOverlayView(state: state) {
                await initialize(id: id)
            }
        }
        .navigationTitle("company.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .initialTask(id: id) {
            await initialize(id: id)
        }
    }

    @ViewBuilder private var content: some View {
        Section("company.admin.section.company") {
            RouterLink(open: .screen(.company(company.id))) {
                CompanyView(company: company)
            }
        }
        .customListRowBackground()
        ModificationInfoView(modificationInfo: company)
        Section("admin.section.details") {
            LabeledTextFieldView(title: "labels.name", text: $name)
            LabeledIdView(id: company.id.rawValue.formatted())
            VerificationAdminToggleView(isVerified: company.isVerified, action: { isVerified in
                await verifyCompany(id: id, isVerified: isVerified)
            })
        }
        .customListRowBackground()
        EditLogoSectionView(logos: company.logos, onUpload: { data in
            await uploadLogo(id: id, data)
        }, onDelete: deleteLogo)
        Section {
            RouterLink(
                "subsidiaries.navigationTitle",
                systemImage: "square.on.square.dashed",
                count: company.subsidiaries.count,
                open: .screen(.subsidiaries(company: $company))
            )
            RouterLink(
                "product.admin.variants.navigationTitle",
                systemImage: "square.stack",
                count: company.productVariants.count,
                open: .screen(.companyProductVariants(variants: company.productVariants))
            )
            RouterLink(
                "admin.section.reports.title",
                systemImage: "exclamationmark.bubble",
                badge: company.reports.count,
                open: .screen(
                    .reports(reports: $company.map(getter: { location in
                        location.reports
                    }, setter: { reports in
                        company.copyWith(reports: reports)
                    })))
            )
            RouterLink("admin.section.editSuggestions.title", systemImage: "square.and.pencil", badge: company.editSuggestions.unresolvedCount, open: .screen(.companyEditSuggestion(company: $company)))
        }
        .customListRowBackground()
        Section {
            MergeCompaniesButtonView(company: company, onMerge: mergeCompanies)
            ConfirmedDeleteButtonView(presenting: company, action: deleteCompany, description: "company.delete.confirmationDialog.title", label: "company.delete.confirmationDialog.label \(company.name)", isDisabled: company.isVerified)
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItem(placement: .primaryAction) {
            AsyncButton("labels.edit", action: {
                await editCompany()
            })
            .disabled(!isValidNameUpdate)
        }
    }

    private func initialize(id: Company.Id) async {
        do {
            let company = try await repository.company.getDetailed(id: id)
            self.company = company
            name = company.name
            state = .populated
            if let open {
                switch open {
                case let .report(id):
                    router.open(.screen(
                        .reports(reports: $company.map(getter: { location in
                            location.reports
                        }, setter: { reports in
                            company.copyWith(reports: reports)
                        }), initialReport: id)))
                case let .editSuggestions(id):
                    router.open(.screen(.companyEditSuggestion(company: $company, initialEditSuggestion: id)))
                }
                self.open = nil
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error(error)
            logger.error("Failed to load company. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func verifyCompany(id: Company.Id, isVerified: Bool) async {
        do {
            try await repository.company.verification(id: id, isVerified: isVerified)
            company = company.copyWith(isVerified: isVerified)
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to verify company. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func mergeCompanies(_ id: Company.Id, mergeToId: Company.Id) async {
        do {
            try await repository.company.mergeCompanies(id: id, mergeToId: mergeToId)
            self.id = mergeToId
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to merge companies. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func editCompany() async {
        do {
            let company = try await repository.company.update(updateRequest: Company.UpdateRequest(id: id, name: name))
            self.company = company
            router.open(.toast(.success()))
            await onUpdate(company)
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to edit company. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteCompany(_ company: Company.Detailed) async {
        do {
            try await repository.company.delete(id: company.id)
            onDelete(company.id)
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete company '\(company.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func uploadLogo(id: Company.Id, _ data: Data) async {
        do {
            let imageEntity = try await repository.company.uploadLogo(id: id, data: data)
            company = company.copyWith(logos: company.logos + [imageEntity])
            logger.info("Succesfully uploaded company logo: \(imageEntity.file)")
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Uploading company logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteLogo(_ entity: ImageEntity.Saved) async {
        do {
            try await repository.imageEntity.delete(from: .companyLogos, id: entity.id)
            company = company.copyWith(logos: company.logos.removing(entity))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct MergeCompaniesButtonView: View {
    @State private var mergeToCompany: Company.Saved?

    let company: Company.Detailed
    let onMerge: (_ id: Company.Id, _ mergeTo: Company.Id) async -> Void

    var body: some View {
        RouterLink("company.admin.mergeCompanies.label", systemImage: "arrow.triangle.merge", open: .sheet(.companyPicker(onSelect: { company in
            mergeToCompany = company
        })))
        .foregroundColor(.primary)
        .confirmationDialog(
            "company.admin.mergeCompanies.description",
            isPresented: $mergeToCompany.isNotNull(),
            titleVisibility: .visible,
            presenting: mergeToCompany
        ) { presenting in
            AsyncButton(
                "company.admin.mergeCompanies.apply \(company.name) \(presenting.name)",
                action: {
                    await onMerge(company.id, presenting.id)
                }
            )
            .tint(.green)
        }
    }
}
