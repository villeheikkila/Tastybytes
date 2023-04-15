import CachedAsyncImage
import PhotosUI
import SwiftUI

struct EditCompanySheet: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss

  let onSuccess: () async -> Void

  init(_ client: Client, company: Company, onSuccess: @escaping () async -> Void, mode: Mode) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, company: company, mode: mode))
    self.onSuccess = onSuccess
  }

  var body: some View {
    Form {
      companyPhotoSection
      Section(viewModel.mode.nameSectionHeader) {
        TextField("Name", text: $viewModel.newCompanyName)
        ProgressButton(viewModel.mode.primaryAction, action: {
          await viewModel.submit(onSuccess: {
            dismiss()
            await onSuccess()
          })
        })
        .disabled(!viewModel.newCompanyName.isValidLength(.normal))
      }
    }
    .navigationTitle(viewModel.mode.navigationTitle)
    .navigationBarItems(trailing: Button("Cancel", role: .cancel, action: { dismiss() }).bold())
  }

  @ViewBuilder var companyPhotoSection: some View {
    if profileManager.hasPermission(.canAddCompanyLogo) {
      Section("Logo") {
        PhotosPicker(
          selection: $viewModel.selectedItem,
          matching: .images,
          photoLibrary: .shared()
        ) {
          if let logoUrl = viewModel.company.logoUrl {
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

  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "EditCompanySheet")
    let client: Client
    let mode: Mode
    @Published var company: Company
    @Published var newCompanyName = ""
    @Published var selectedItem: PhotosPickerItem? {
      didSet {
        if selectedItem != nil {
          Task {
            await uploadCompanyImage()
          }
        }
      }
    }

    init(_ client: Client, company: Company, mode: Mode) {
      self.client = client
      self.company = company
      self.mode = mode
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
}
