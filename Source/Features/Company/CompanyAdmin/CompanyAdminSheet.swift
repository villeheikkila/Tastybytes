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

    let onSuccess: () async -> Void

    init(company: Company, onSuccess: @escaping () async -> Void) {
        _company = State(initialValue: .init(company: company))
        _newCompanyName = State(initialValue: company.name)
        self.onSuccess = onSuccess
    }

    var body: some View {
        Form {
            if state == .populated {
                populatedContent
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

    @ViewBuilder private var populatedContent: some View {
        Section("company.admin.section.company") {
            RouterLink(open: .screen(.company(.init(company: company)))) {
                CompanyEntityView(company: company)
            }
        }

        CreationInfoSection(createdBy: company.createdBy, createdAt: company.createdAt)

        Section("admin.section.details") {
            LabeledTextField(title: "labels.name", text: $newCompanyName)
            LabeledContent("labels.id", value: "\(company.id)")
                .textSelection(.enabled)
                .multilineTextAlignment(.trailing)
            VerificationAdminToggleView(isVerified: company.isVerified) { isVerified in
                await verifyCompany(isVerified: isVerified)
            }
        }

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

        ConfirmedDeleteButtonView(presenting: company, action: deleteCompany, description: "company.delete.confirmationDialog.title", label: "company.delete.confirmationDialog.label \(company.name)", isDisabled: company.isVerified)
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItem(placement: .primaryAction) {
            ProgressButton("labels.edit", action: {
                await editCompany()
            })
            .disabled(!newCompanyName.isValidLength(.normal) || newCompanyName == company.name)
        }
    }

    func loadData() async {
        switch await repository.company.getManagementDataById(id: company.id) {
        case let .success(company):
            withAnimation {
                self.company = company
                state = .populated
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to edit company. Error: \(error) (\(#file):\(#line))")
        }
    }

    func verifyCompany(isVerified: Bool) async {
        switch await repository.company.verification(id: company.id, isVerified: isVerified) {
        case .success:
            company = company.copyWith(isVerified: isVerified)
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to verify company. Error: \(error) (\(#file):\(#line))")
        }
    }

    func editCompany() async {
        switch await repository.company.update(updateRequest: Company.UpdateRequest(id: company.id, name: newCompanyName)) {
        case let .success(company):
            withAnimation {
                self.company = .init(company: .init(company: company))
            }
            router.open(.toast(.success()))
            await onSuccess()
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to edit company. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteCompany(_ company: Company.Management) async {
        switch await repository.company.delete(id: company.id) {
        case .success:
            router.open(.toast(.success()))
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete company '\(company.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func uploadLogo(_ data: Data) async {
        switch await repository.company.uploadLogo(companyId: company.id, data: data) {
        case let .success(imageEntity):
            company = company.copyWith(logos: company.logos + [imageEntity])
            logger.info("Succesfully uploaded company logo: \(imageEntity.file)")
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Uploading company logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteLogo(_ entity: ImageEntity) async {
        switch await repository.imageEntity.delete(from: .companyLogos, entity: entity) {
        case .success:
            withAnimation {
                company = company.copyWith(logos: company.logos.removing(entity))
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }
}
