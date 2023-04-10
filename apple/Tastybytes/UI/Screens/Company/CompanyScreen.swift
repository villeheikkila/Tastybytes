import CachedAsyncImage
import PhotosUI
import SwiftUI

struct CompanyScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var toastManager: ToastManager
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
        ForEach(viewModel.sortedBrands) { brand in
          RouteLink(to: .brand(Brand.JoinedSubBrandsProductsCompany(brandOwner: viewModel.company, brand: brand))) {
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
    .refreshable {
      await hapticManager.wrapWithHaptics {
        await viewModel.getBrandsAndSummary()
      }
    }
    .toolbar {
      toolbarContent
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
          hapticManager.trigger(.notification(.success))
          router.reset()
        })
      })
    }
    .task {
      if viewModel.summary == nil {
        await viewModel.getBrandsAndSummary()
      }
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .principal) {
      HStack(alignment: .center, spacing: 18) {
        if let logoUrl = viewModel.company.logoUrl {
          CachedAsyncImage(url: logoUrl, urlCache: .imageCache) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 32, height: 32)
              .accessibility(hidden: true)
          } placeholder: {
            ProgressView()
          }
        }
        Text(viewModel.company.name)
          .font(.headline)
      }
    }
    ToolbarItem(placement: .navigationBarTrailing) {
      navigationBarMenu
    }
  }

  private var navigationBarMenu: some View {
    Menu {
      ShareLink("Share", item: NavigatablePath.company(id: viewModel.company.id).url)

      if profileManager.hasPermission(.canCreateBrands) {
        Button(action: { router.openSheet(.addBrand(brandOwner: viewModel.company, mode: .new, onSelect: { brand, _ in
          router.fetchAndNavigateTo(viewModel.client, .brand(id: brand.id), resetStack: false)
        })) }, label: {
          Label("Add Brand", systemImage: "plus")
        })
      }

      if profileManager.hasPermission(.canEditCompanies) {
        Button(action: { router.openSheet(.editCompany(company: viewModel.company, onSuccess: {
          Task {
            await hapticManager.wrapWithHaptics {
              await viewModel.getBrandsAndSummary()
            }
          }
          toastManager.toggle(.success("Company updated"))
        })) }, label: {
          Label("Edit", systemImage: "pencil")
        })
      } else {
        Button(action: { router.openSheet(.companyEditSuggestion(company: viewModel.company, onSubmit: {
          toastManager.toggle(.success("Edit suggestion sent!"))
        })) }, label: {
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

      ReportButton(entity: .company(viewModel.company))

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

  private var companyHeader: some View {
    HStack(spacing: 10) {
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
      }
      Spacer()
    }
  }
}
