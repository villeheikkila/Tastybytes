import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

@MainActor
struct EditCompanySheet: View {
    private let logger = Logger(category: "EditCompanySheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var company: Company
    @State private var newCompanyName = ""
    @State private var alertError: AlertError?
    @State private var selectedLogo: PhotosPickerItem?

    let mode: Mode
    let onSuccess: () async -> Void

    init(company: Company, onSuccess: @escaping () async -> Void, mode: Mode) {
        _company = State(initialValue: company)
        _newCompanyName = State(initialValue: company.name)
        self.mode = mode
        self.onSuccess = onSuccess
    }

    var body: some View {
        Form {
            Section(mode.nameSectionHeader) {
                TextField("company.edit.name.placeholder", text: $newCompanyName)
                ProgressButton(mode.primaryAction, action: {
                    await submit(onSuccess: {
                        dismiss()
                        await onSuccess()
                    })
                })
                .disabled(!newCompanyName.isValidLength(.normal))
            }
            .headerProminence(.increased)
            .customListRowBackground()

            EditLogoSection(logos: company.logos, onUpload: { imageData in
                await uploadLogo(data: imageData)
            }, onDelete: { imageEntity in
                await deleteLogo(entity: imageEntity)
            })

            if profileEnvironmentModel.hasRole(.admin) {
                Section("labels.info") {
                    LabeledContent("labels.id", value: "\(company.id)")
                        .textSelection(.enabled)
                    LabeledContent("verification.verified.label", value: "\(company.isVerified)".capitalized)
                }
                .headerProminence(.increased)
                .customListRowBackground()
            }
        }
        .scrollContentBackground(.hidden)
        .alertError($alertError)
        .navigationTitle(mode.navigationTitle)
        .toolbar {
            toolbarContent
        }
        .task(id: selectedLogo) {
            guard let selectedLogo else { return }
            guard let data = await selectedLogo.getJPEG() else {
                logger.error("Failed to convert image to JPEG")
                return
            }
            await uploadLogo(data: data)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    @ViewBuilder var companyPhotoSection: some View {
        if profileEnvironmentModel.hasPermission(.canAddCompanyLogo) {
            Section("company.logo.title") {
                PhotosPicker(
                    selection: $selectedLogo,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    CompanyLogo(company: company, size: 120)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
    }

    func submit(onSuccess: @MainActor @Sendable () async -> Void) async {
        switch mode {
        case .edit:
            await editCompany(onSuccess: onSuccess)
        case .editSuggestion:
            await sendCompanyEditSuggestion(onSuccess: onSuccess)
        }
    }

    func editCompany(onSuccess: () async -> Void) async {
        switch await repository.company.update(updateRequest: Company.UpdateRequest(id: company.id, name: newCompanyName)) {
        case let .success(company):
            self.company = .init(company: company)
            await onSuccess()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to edit company. Error: \(error) (\(#file):\(#line))")
        }
    }

    func sendCompanyEditSuggestion(onSuccess: () async -> Void) async {
        switch await repository.company.editSuggestion(updateRequest: Company.EditSuggestionRequest(id: company.id, name: newCompanyName)) {
        case .success:
            await onSuccess()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to send company edit suggestion. Error: \(error) (\(#file):\(#line))")
        }
    }

    func uploadLogo(data: Data) async {
        switch await repository.company.uploadLogo(companyId: company.id, data: data) {
        case let .success(imageEntity):
            company = company.copyWith(logos: company.logos + [imageEntity])
            logger.info("Succesfully uploaded company logo: \(imageEntity.file)")
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Uploading company logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteLogo(entity: ImageEntity) async {
        switch await repository.imageEntity.delete(from: .companyLogos, entity: entity) {
        case .success:
            withAnimation {
                company = company.copyWith(logos: company.logos.removing(entity))
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }
}

extension EditCompanySheet {
    enum Mode {
        case edit
        case editSuggestion

        var primaryAction: LocalizedStringKey {
            switch self {
            case .edit:
                "labels.edit"
            case .editSuggestion:
                "labels.send"
            }
        }

        var navigationTitle: LocalizedStringKey {
            switch self {
            case .edit:
                "company.edit.label"
            case .editSuggestion:
                "company.editSuggestion.label"
            }
        }

        var nameSectionHeader: LocalizedStringKey {
            switch self {
            case .edit:
                "company.edit.section.name.title"
            case .editSuggestion:
                "company.editSuggestion.section.name.title"
            }
        }
    }
}
