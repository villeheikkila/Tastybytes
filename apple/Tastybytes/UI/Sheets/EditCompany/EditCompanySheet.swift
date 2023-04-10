import CachedAsyncImage
import PhotosUI
import SwiftUI

struct EditCompanySheet: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss

  let onSuccess: () -> Void

  init(_ client: Client, company: Company, onSuccess: @escaping () -> Void) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, company: company))
    self.onSuccess = onSuccess
  }

  var body: some View {
    Form {
      if profileManager.hasPermission(.canAddCompanyLogo) {
        Section {
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
        } header: {
          Text("Logo")
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
      }
      Section {
        TextField("Name", text: $viewModel.newCompanyName)
        ProgressButton("Edit", action: {
          await viewModel.editCompany(onSuccess: {
            onSuccess()
          })
        })
        .disabled(!viewModel.newCompanyName.isValidLength(.normal))
      } header: {
        Text("Company name")
      }
    }
    .navigationTitle("Edit Company")
    .navigationBarItems(trailing: Button(action: { dismiss() }, label: {
      Text("Done").bold()
    }))
  }
}

extension EditCompanySheet {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "EditCompanySheet")
    let client: Client
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

    init(_ client: Client, company: Company) {
      self.client = client
      self.company = company
    }

    func editCompany(onSuccess: () -> Void) async {
      switch await client.company
        .update(updateRequest: Company.UpdateRequest(id: company.id, name: newCompanyName))
      {
      case .success:
        onSuccess()
      case let .failure(error):
        logger.error("failed to edit company: \(error.localizedDescription)")
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
        logger
          .error(
            "uplodaing company logo failed: \(error.localizedDescription)"
          )
      }
    }
  }
}
