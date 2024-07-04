import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct CompanyAdminSheet: View {
    private let logger = Logger(category: "EditCompanySheet")
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
                CompanyResultInnerView(company: company)
            }
        }

        Section("location.admin.section.creator") {
            HStack {
                if let createdBy = company.createdBy {
                    Avatar(profile: createdBy)
                }
                VStack(alignment: .leading) {
                    Text(company.createdBy?.preferredName ?? "-")
                    if let createdAt = company.createdAt {
                        Text(createdAt, format:
                            .dateTime
                                .year()
                                .month(.wide)
                                .day())
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
            .contentShape(.rect)
            .ifLet(company.createdBy) { view, createdBy in
                view.openOnTap(.screen(.profile(createdBy)))
            }
        }

        Section("company.admin.section.details") {
            LabeledTextField(title: "labels.name", text: $newCompanyName)
            LabeledContent("labels.id", value: "\(company.id)")
                .textSelection(.enabled)
            LabeledContent("verification.verified.label", value: "\(company.isVerified)".capitalized)
        }

        EditLogoSection(logos: company.logos, onUpload: uploadLogo, onDelete: deleteLogo)

        Section {
            RouterLink("admin.section.reports.title", systemImage: "exclamationmark.bubble", open: .screen(.reports(.company(company.id))))
            RouterLink("admin.section.editSuggestions.title", systemImage: "square.and.pencil", open: .screen(.companyEditSuggestion(company: $company)))
            Button(
                "labels.delete",
                systemImage: "trash.fill",
                role: .destructive,
                action: { showDeleteCompanyConfirmationDialog = true }
            )
            .foregroundColor(.red)
            .disabled(company.isVerified)
            .confirmationDialog("company.delete.confirmationDialog.title",
                                isPresented: $showDeleteCompanyConfirmationDialog,
                                presenting: company)
            { presenting in
                ProgressButton("company.delete.confirmationDialog.label \(presenting.name)", role: .destructive, action: {
                    await deleteCompany(presenting)
                })
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItem(placement: .primaryAction) {
            ProgressButton("labels.edit", action: {
                await editCompany(onSuccess: onSuccess)
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

    func editCompany(onSuccess: () async -> Void) async {
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

struct CompanyEditSuggestionScreen: View {
    @Binding var company: Company.Management

    var body: some View {
        List(company.editSuggestions) { editSuggestion in
            CompanyEditSuggestionRow(company: $company, editSuggestion: editSuggestion)
        }
        .overlay {
            if company.editSuggestions.isEmpty {
                ContentUnavailableView("No Edit Suggestions", systemImage: "tray")
            }
        }
        .listStyle(.plain)
        .navigationTitle("company.admin.editSuggestion.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CompanyEditSuggestionRow: View {
    private let logger = Logger(category: "CompanyEditSuggestionRow")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @State private var showApplyConfirmationDialog = false
    @State private var showDeleteConfirmationDialog = false
    @Binding var company: Company.Management
    let editSuggestion: Company.EditSuggestion

    var body: some View {
        HStack(alignment: .top) {
            if let profile = editSuggestion.createdBy {
                Avatar(profile: profile)
                    .avatarSize(.medium)
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Group {
                        if let profile = editSuggestion.createdBy {
                            Text(profile.preferredName)
                        } else {
                            Text("-")
                        }
                    }
                    .font(.caption)
                    Spacer()
                    Text(editSuggestion.createdAt.formatted(.customRelativetime)).font(.caption2)
                }
                Text("company.admin.editSuggestion.changeNameTo.label \(company.name) \(editSuggestion.name)")
                    .font(.callout)
            }
            Spacer()
        }
        .padding(.vertical, 2)
        .swipeActions {
            Button("company.admin.editSuggestion.delete.label", systemImage: "trash") {
                showDeleteConfirmationDialog = true
            }
            .tint(.red)
            Button("company.admin.editSuggestion.apply.label", systemImage: "checkmark") {
                showApplyConfirmationDialog = true
            }
            .tint(.green)
        }
        .confirmationDialog(
            "company.admin.editSuggestion.apply.description",
            isPresented: $showApplyConfirmationDialog,
            titleVisibility: .visible,
            presenting: editSuggestion
        ) { presenting in
            Button(
                "company.admin.editSuggestion.apply.label \(company.name) \(presenting.name)",
                action: {
                    withAnimation {
                        company = company.copyWith(name: presenting.name)
                    }
                    router.removeLast()
                }
            )
            .tint(.green)
        }
        .confirmationDialog(
            "company.admin.editSuggestion.delete.description",
            isPresented: $showDeleteConfirmationDialog,
            titleVisibility: .visible,
            presenting: editSuggestion
        ) { presenting in
            ProgressButton(
                "company.admin.editSuggestion.delete.label \(presenting.name)",
                action: {
                  await  deleteEditSuggestion(presenting)
                }
            )
            .tint(.green)
        }
        .listRowBackground(Color.clear)
    }

    func deleteEditSuggestion(_ editSuggestion: Company.EditSuggestion) async {
        switch await repository.company.deleteEditSuggestion(editSuggestion: editSuggestion) {
        case .success:
            withAnimation {
                company = company.copyWith(editSuggestions: company.editSuggestions.removing(editSuggestion))
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete company '\(company.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
