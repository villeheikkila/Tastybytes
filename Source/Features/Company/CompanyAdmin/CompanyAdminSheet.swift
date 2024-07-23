import Components
import EnvironmentModels
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
    @State private var showDeleteCompanyConfirmationDialog = false
    @State private var company = Company.Detailed()
    @State private var name = ""
    @State private var selectedLogo: PhotosPickerItem?

    let id: Company.Id
    let open: Open?
    let onUpdate: OnUpdateCallback
    let onDelete: OnDeleteCallback

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
                await initialize()
            }
        }
        .navigationTitle("company.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .initialTask {
            await initialize()
        }
        .task(id: selectedLogo) {
            guard let selectedLogo else { return }
            guard let data = await selectedLogo.getJPEG() else {
                logger.error("Failed to convert image to JPEG")
                return
            }
            await uploadLogo(data)
        }
    }

    @ViewBuilder private var content: some View {
        Section("company.admin.section.company") {
            RouterLink(open: .screen(.company(.init(company: company)))) {
                CompanyEntityView(company: company)
            }
        }
        .customListRowBackground()
        ModificationInfoView(modificationInfo: company)
        Section("admin.section.details") {
            LabeledTextFieldView(title: "labels.name", text: $name)
            LabeledIdView(id: company.id.rawValue.formatted())
            VerificationAdminToggleView(isVerified: company.isVerified, action: verifyCompany)
        }
        .customListRowBackground()
        EditLogoSection(logos: company.logos, onUpload: uploadLogo, onDelete: deleteLogo)
        Section {
            RouterLink(
                "subsidiaries.navigationTitle",
                systemImage: "square.on.square.dashed",
                count: company.subsidiaries.count,
                open: .screen(.subsidiaries(company: $company))
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

    private func initialize() async {
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
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to load company. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func verifyCompany(isVerified: Bool) async {
        do {
            try await repository.company.verification(id: id, isVerified: isVerified)
            company = company.copyWith(isVerified: isVerified)
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to verify company. Error: \(error) (\(#file):\(#line))")
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

    private func uploadLogo(_ data: Data) async {
        do {
            let imageEntity = try await repository.company.uploadLogo(companyId: id, data: data)
            company = company.copyWith(logos: company.logos + [imageEntity])
            logger.info("Succesfully uploaded company logo: \(imageEntity.file)")
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Uploading company logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteLogo(_ entity: ImageEntity) async {
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

struct CompanySubsidiaryScreen: View {
    private let logger = Logger(category: "CompanySubsidiaryScreen")
    @Environment(Repository.self) private var repository
    @State private var companyToAttach: Company?
    @Binding var company: Company.Detailed

    var body: some View {
        List(company.subsidiaries) { subsidiary in
            RouterLink(open: .screen(.company(subsidiary))) {
                CompanyEntityView(company: subsidiary)
            }
        }
        .toolbar {
            toolbarContent
        }
        .navigationTitle("subsidiaries.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if company.subsidiaries.isEmpty {
                ContentUnavailableView(" subsidaries.empty.title", systemImage: "tray")
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            RouterLink("subsidiaries.pickCompany", systemImage: "plus", open: .sheet(.companyPicker(filterCompanies: company.subsidiaries + [.init(company: company)], onSelect: { company in
                companyToAttach = company
            })))
            .labelStyle(.iconOnly)
            .confirmationDialog("subsidiaries.makeSubsidiaryOf.confirmation.title",
                                isPresented: $companyToAttach.isNotNull(),
                                titleVisibility: .visible,
                                presenting: companyToAttach)
            { presenting in
                AsyncButton(
                    "subsidiaries.makeSubsidiaryOf.confirmation.label \(presenting.name) \(company.name)",
                    action: {
                        await makeCompanySubsidiaryOf(subsidiaryOf: company, presenting)
                    }
                )
            }
        }
    }

    func makeCompanySubsidiaryOf(subsidiaryOf: Company.Detailed, _ company: Company) async {
        do {
            try await repository.company.makeCompanySubsidiaryOf(company: company, subsidiaryOf: subsidiaryOf)
            self.company = subsidiaryOf.copyWith(subsidiaries: subsidiaryOf.subsidiaries + [company])
        } catch {
            logger.error("Failed to make company a subsidiary")
        }
    }
}
