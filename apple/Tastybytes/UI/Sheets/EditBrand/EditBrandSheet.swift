import AlertToast
import CachedAsyncImage
import PhotosUI
import SwiftUI

struct EditBrandSheet: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var router: Router

  let onUpdate: () -> Void

  init(
    _ client: Client,
    brand: Brand.JoinedSubBrandsProductsCompany,
    onUpdate: @escaping () -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, brand: brand, onUpdate: onUpdate))
    self.onUpdate = onUpdate
  }

  var body: some View {
    Form {
      if profileManager.hasPermission(.canAddBrandLogo) {
        Section {
          PhotosPicker(
            selection: $viewModel.selectedLogo,
            matching: .images,
            photoLibrary: .shared()
          ) {
            if let logoUrl = viewModel.brand.logoUrl {
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
        TextField("Name", text: $viewModel.name)
        ProgressButton("Edit") {
          await viewModel.editBrand {
            onUpdate()
          }
        }.disabled(!viewModel.name.isValidLength(.normal) || viewModel.brand.name == viewModel.name)
      } header: {
        Text("Brand name")
      }

      Section {
        Button(action: { router.navigate(sheet: .companySearch(onSelect: { company, _ in
          viewModel.brandOwner = company
        })) }, label: {
          Text(viewModel.brandOwner.name)
        })
        ProgressButton("Change brand owner") {
          await viewModel.editBrand {
            onUpdate()
          }
        }.disabled(viewModel.brandOwner.id == viewModel.initialBrandOwner.id)
      } header: {
        Text("Brand Owner")
      }
    }
    .navigationTitle("Edit Brand")
    .navigationBarItems(trailing: Button(action: { dismiss() }, label: {
      Text("Done").bold()
    }))
    .toast(isPresenting: $viewModel.showToast, duration: 2, tapToDismiss: true) {
      AlertToast(type: .complete(.green), title: "Brand updated!")
    }
  }
}
