import CachedAsyncImage
import PhotosUI
import SwiftUI

struct EditCompanySheet: View {
  private let logger = getLogger(category: "EditCompanySheet")
  @EnvironmentObject private var client: AppClient
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss
  @State private var company: Company
  @State private var newCompanyName = ""
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
    _company = State(wrappedValue: company)
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
    .navigationTitle(mode.navigationTitle)
    .navigationBarItems(trailing: Button("Cancel", role: .cancel, action: { dismiss() }).bold())
  }

  @ViewBuilder var companyPhotoSection: some View {
    if profileManager.hasPermission(.canAddCompanyLogo) {
      Section("Logo") {
        PhotosPicker(
          selection: $selectedItem,
          matching: .images,
          photoLibrary: .shared()
        ) {
          if let logoUrl = company.logoUrl {
            CachedAsyncImage(url: logoUrl, urlCache: .imageCache) { image in
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 52, height: 52)
                .accessibility(hidden: true)
            } placeholder: {
              Image(systemName: "photo")
                .accessibility(hidden: true)
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

  func submit(onSuccess: () async -> Void) async {
    switch mode {
    case .edit:
      await editCompany(onSuccess: onSuccess)
    case .editSuggestion:
      await sendCompanyEditSuggestion(onSuccess: onSuccess)
    }
  }

  func editCompany(onSuccess: () async -> Void) async {
    switch await client.company
      .update(updateRequest: Company.UpdateRequest(id: company.id, name: newCompanyName))
    {
    case .success:
      await onSuccess()
    case let .failure(error):
      logger.error("failed to edit company: \(error.localizedDescription)")
    }
  }

  func sendCompanyEditSuggestion(onSuccess: () async -> Void) async {
    switch await client.company
      .editSuggestion(updateRequest: Company.EditSuggestionRequest(id: company.id, name: newCompanyName))
    {
    case .success:
      await onSuccess()
    case let .failure(error):
      logger.error("failed to send company edit suggestion: \(error.localizedDescription)")
    }
  }

  func uploadCompanyImage() async {
    guard let data = await selectedItem?.getJPEG() else { return }
    switch await client.company.uploadLogo(companyId: company.id, data: data) {
    case let .success(fileName):
      company = Company(
        id: company.id,
        name: company.name,
        logoFile: fileName,
        isVerified: company.isVerified
      )
    case let .failure(error):
      logger.error("uplodaing company logo failed: \(error.localizedDescription)")
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
        return "Edit"
      case .editSuggestion:
        return "Send"
      }
    }

    var navigationTitle: String {
      switch self {
      case .edit:
        return "Edit Company"
      case .editSuggestion:
        return "Edit Suggestion"
      }
    }

    var nameSectionHeader: String {
      switch self {
      case .edit:
        return "Company name"
      case .editSuggestion:
        return "What should the company be called?"
      }
    }
  }
}
