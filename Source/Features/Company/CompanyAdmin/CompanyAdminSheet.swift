import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct CompanyAdminSheet: View {
    private let logger = Logger(category: "CompanyAdminSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var state: ScreenState = .loading
    @State private var showDeleteCompanyConfirmationDialog = false
    @State private var company: Company.Management
    @State private var newCompanyName = ""
    @State private var selectedLogo: PhotosPickerItem?

    let onUpdate: () async -> Void
    let onDelete: () -> Void

    init(company: Company, onUpdate: @escaping () async -> Void, onDelete: @escaping () -> Void) {
        _company = State(initialValue: .init(company: company))
        _newCompanyName = State(initialValue: company.name)
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }

    var body: some View {
        Form {
            if state == .populated {
                content
            }
        }
        .scrollContentBackground(.hidden)
        .overlay {
            ScreenStateOverlayView(state: state, errorDescription: "") {
                await loadData()
            }
        }
        .navigationTitle("company.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .initialTask {
            await loadData()
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
        CreationInfoSection(createdBy: company.createdBy, createdAt: company.createdAt)
        Section("admin.section.details") {
            LabeledTextField(title: "labels.name", text: $newCompanyName)
            LabeledIdView(id: company.id.formatted())
            VerificationAdminToggleView(isVerified: company.isVerified, action: verifyCompany)
        }
        .customListRowBackground()
        EditLogoSection(logos: company.logos, onUpload: uploadLogo, onDelete: deleteLogo)
        Section {
            RouterLink("admin.section.reports.title", systemImage: "exclamationmark.bubble", open: .screen(.reports(.company(company.id))))
            RouterLink(open: .screen(.companyEditSuggestion(company: $company))) {
                HStack {
                    Label("admin.section.editSuggestions.title", systemImage: "square.and.pencil")
                    Spacer()
                    Text("(\(company.editSuggestions.count.formatted()))")
                }
            }
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
            ProgressButton("labels.edit", action: {
                await editCompany()
            })
            .disabled(!newCompanyName.isValidLength(.normal(allowEmpty: false)) || newCompanyName == company.name)
        }
    }

    func loadData() async {
        do {
            let company = try await repository.company.getManagementDataById(id: company.id)
            withAnimation {
                self.company = company
                state = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to edit company. Error: \(error) (\(#file):\(#line))")
        }
    }

    func verifyCompany(isVerified: Bool) async {
        do {
            try await repository.company.verification(id: company.id, isVerified: isVerified)
            company = company.copyWith(isVerified: isVerified)
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to verify company. Error: \(error) (\(#file):\(#line))")
        }
    }

    func editCompany() async {
        do {
            let company = try await repository.company.update(updateRequest: Company.UpdateRequest(id: company.id, name: newCompanyName))
            withAnimation {
                self.company = .init(company: .init(company: company))
            }
            router.open(.toast(.success()))
            await onUpdate()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to edit company. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteCompany(_ company: Company.Management) async {
        do { try await repository.company.delete(id: company.id)
            onDelete()
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete company '\(company.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func uploadLogo(_ data: Data) async {
        do {
            let imageEntity = try await repository.company.uploadLogo(companyId: company.id, data: data)
            company = company.copyWith(logos: company.logos + [imageEntity])
            logger.info("Succesfully uploaded company logo: \(imageEntity.file)")
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Uploading company logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteLogo(_ entity: ImageEntity) async {
        do {
            try await repository.imageEntity.delete(from: .companyLogos, entity: entity)
            withAnimation {
                company = company.copyWith(logos: company.logos.removing(entity))
            }
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }
}
