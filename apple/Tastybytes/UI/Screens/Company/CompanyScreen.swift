import CachedAsyncImage
import SwiftUI

struct CompanyScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var router: Router
  @StateObject private var viewModel: ViewModel
  @Environment(\.dismiss) private var dismiss

  init(_ client: Client, company: Company) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, company: company))
  }

  var body: some View {
    List {
      if let summary = viewModel.summary, summary.averageRating != nil {
        Section {
          SummaryView(summary: summary)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
      }
      Section {
        ForEach(viewModel.sortedBrands) { brand in NavigationLink(value: Route
            .brand(Brand.JoinedSubBrandsProductsCompany(brandOwner: viewModel.company, brand: brand)))
        {
          HStack {
            Text("\(brand.name)")
            Spacer()
            Text("(\(brand.getNumberOfProducts()))")
          }
        }
        }
      } header: {
        Text("Brands")
      }
      .headerProminence(.increased)
    }
    .listStyle(.plain)
    .navigationTitle(viewModel.company.name)
    .refreshable {
      viewModel.getBrandsAndSummary()
    }
    .navigationBarItems(trailing: navigationBarMenu)
    .sheet(item: $viewModel.activeSheet) { sheet in
      NavigationStack {
        switch sheet {
        case .editSuggestionCompany:
          companyEditSuggestionSheet
        case .editCompany:
          companyEditSheet
        case .addBrand:
          BrandSheet(viewModel.client, brandOwner: viewModel.company, mode: .new, onSelect: { brand, _ in
            viewModel.activeSheet = nil
            router.fetchAndNavigateTo(viewModel.client, .brand(id: brand.id), resetStack: false)
          })
        }
      }
    }
    .confirmationDialog("Unverify Company",
                        isPresented: $viewModel.showUnverifyCompanyConfirmation,
                        presenting: viewModel.company)
    { presenting in
      Button("Unverify \(presenting.name) company", role: .destructive, action: {
        viewModel.verifyCompany(isVerified: false)
      })
    }
    .confirmationDialog("Delete Company Confirmation",
                        isPresented: $viewModel.showDeleteCompanyConfirmationDialog,
                        presenting: viewModel.company)
    { presenting in
      Button("Delete \(presenting.name) Company", role: .destructive, action: {
        viewModel.deleteCompany(viewModel.company, onDelete: {
          hapticManager.trigger(of: .notification(.success))
          router.reset()
        })
      })
    }
    .task {
      viewModel.getBrandsAndSummary()
    }
  }

  private var navigationBarMenu: some View {
    Menu {
      ShareLink("Share", item: NavigatablePath.company(id: viewModel.company.id).url)

      if profileManager.hasPermission(.canCreateBrands) {
        Button(action: { viewModel.setActiveSheet(.addBrand) }, label: {
          Label("Add Brand", systemImage: "plus")
        })
      }

      if profileManager.hasPermission(.canEditCompanies) {
        Button(action: { viewModel.setActiveSheet(.editCompany) }, label: {
          Label("Edit", systemImage: "pencil")
        })
      } else {
        Button(action: { viewModel.setActiveSheet(.editSuggestionCompany) }, label: {
          Label("Edit Suggestion", systemImage: "pencil")
        })
      }

      Divider()

      if viewModel.company.isVerified {
        Button(action: { viewModel.showUnverifyCompanyConfirmation = true }, label: {
          Label("Verified", systemImage: "checkmark.circle")
        })
      } else if profileManager.hasPermission(.canVerify) {
        Button(action: { viewModel.verifyCompany(isVerified: true) }, label: {
          Label("Verify", systemImage: "checkmark")
        })
      } else {
        Label("Not verified", systemImage: "x.circle")
      }

      if profileManager.hasPermission(.canDeleteCompanies) {
        Button(role: .destructive, action: { viewModel.showDeleteCompanyConfirmationDialog.toggle() }, label: {
          Label("Delete", systemImage: "trash.fill")
        })
        .disabled(viewModel.company.isVerified)
      }
    } label: {
      Label("Options menu", systemImage: "ellipsis")
        .labelStyle(.iconOnly)
    }
  }

  private var companyEditSuggestionSheet: some View {
    Form {
      Section {
        TextField("Name", text: $viewModel.newCompanyNameSuggestion)
        Button("Send") {
          viewModel.sendCompanyEditSuggestion()
        }
        .disabled(!validateStringLength(str: viewModel.newCompanyNameSuggestion, type: .normal))
      } header: {
        Text("What should the company be called?")
      }
    }
    .navigationTitle("Edit suggestion")
  }

  private var companyEditSheet: some View {
    Form {
      Section {
        TextField("Name", text: $viewModel.newCompanyNameSuggestion)
        Button("Edit") {
          viewModel.editCompany()
        }
        .disabled(!validateStringLength(str: viewModel.newCompanyNameSuggestion, type: .normal))
      } header: {
        Text("Company name")
      }
    }
    .navigationTitle("Edit Company")
    .navigationBarItems(trailing: Button(action: { dismiss() }, label: {
      Text("Done").bold()
    }))
  }

  private var companyHeader: some View {
    HStack(spacing: 10) {
      if let logoUrl = viewModel.company.getLogoUrl() {
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
      }
      Spacer()
    }
  }
}
