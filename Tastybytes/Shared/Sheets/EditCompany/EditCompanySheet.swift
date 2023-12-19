import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct EditCompanySheet: View {
    private let logger = Logger(category: "EditCompanySheet")
    @Environment(\.repository) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var company: Company
    @State private var newCompanyName = ""
    @State private var alertError: AlertError?
    @State private var selectedItem: PhotosPickerItem? {
        didSet {
            if selectedItem != nil {
                Task {
                    await uploadCompanyImage()
                }
            }
        }
    }

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
            companyPhotoSection
            Section(mode.nameSectionHeader) {
                TextField("Name", text: $newCompanyName)
                ProgressButton(mode.primaryAction, action: {
                    await submit(onSuccess: {
                        dismiss()
                        await onSuccess()
                    })
                })
                .disabled(!newCompanyName.isValidLength(.normal))
            }
        }
        .alertError($alertError)
        .navigationTitle(mode.navigationTitle)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Cancel", role: .cancel, action: { dismiss() })
        }
    }

    @MainActor
    @ViewBuilder var companyPhotoSection: some View {
        if profileEnvironmentModel.hasPermission(.canAddCompanyLogo) {
            Section("Logo") {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    if let logoUrl = company.logoUrl {
                        RemoteImage(url: logoUrl) { state in
                            if let image = state.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 52, height: 52)
                                    .accessibility(hidden: true)
                            } else {
                                Image(systemName: "photo")
                                    .accessibility(hidden: true)
                            }
                        }
                    } else {
                        Image(systemName: "photo")
                            .accessibility(hidden: true)
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
    }

    func submit(onSuccess: @Sendable () async -> Void) async {
        switch mode {
        case .edit:
            await editCompany(onSuccess: onSuccess)
        case .editSuggestion:
            await sendCompanyEditSuggestion(onSuccess: onSuccess)
        }
    }

    func editCompany(onSuccess: () async -> Void) async {
        switch await repository.company
            .update(updateRequest: Company.UpdateRequest(id: company.id, name: newCompanyName))
        {
        case .success:
            await onSuccess()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to edit company. Error: \(error) (\(#file):\(#line))")
        }
    }

    func sendCompanyEditSuggestion(onSuccess: () async -> Void) async {
        switch await repository.company
            .editSuggestion(updateRequest: Company.EditSuggestionRequest(id: company.id, name: newCompanyName))
        {
        case .success:
            await onSuccess()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to send company edit suggestion. Error: \(error) (\(#file):\(#line))")
        }
    }

    func uploadCompanyImage() async {
        guard let data = await selectedItem?.getJPEG() else { return }
        switch await repository.company.uploadLogo(companyId: company.id, data: data) {
        case let .success(fileName):
            company = Company(
                id: company.id,
                name: company.name,
                logoFile: fileName,
                isVerified: company.isVerified
            )
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Uplodaing company logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}

extension EditCompanySheet {
    enum Mode {
        case edit
        case editSuggestion

        var primaryAction: String {
            switch self {
            case .edit:
                "Edit"
            case .editSuggestion:
                "Send"
            }
        }

        var navigationTitle: String {
            switch self {
            case .edit:
                "Edit Company"
            case .editSuggestion:
                "Edit Suggestion"
            }
        }

        var nameSectionHeader: String {
            switch self {
            case .edit:
                "Company name"
            case .editSuggestion:
                "What should the company be called?"
            }
        }
    }
}
