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
          RouteLink(screen: .brand(Brand.JoinedSubBrandsProductsCompany(brandOwner: viewModel.company, brand: brand))) {
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
      ProgressButton("Unverify \(presenting.name) company", action: {
        await viewModel.verifyCompany(isVerified: false)
      })
    }
    .confirmationDialog("Delete Company Confirmation",
                        isPresented: $viewModel.showDeleteCompanyConfirmationDialog,
                        presenting: viewModel.company)
    { presenting in
      ProgressButton("Delete \(presenting.name) Company", role: .destructive, action: {
        await viewModel.deleteCompany(viewModel.company, onDelete: {
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
        Button(action: { router.navigate(sheet: .addBrand(brandOwner: viewModel.company, mode: .new, onSelect: { brand, _ in
          router.fetchAndNavigateTo(viewModel.client, .brand(id: brand.id))
        })) }, label: {
          Label("Add Brand", systemImage: "plus")
        })
      }

      if profileManager.hasPermission(.canEditCompanies) {
        Button(action: { router.navigate(sheet: .editCompany(company: viewModel.company, onSuccess: {
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
        Button(action: { router.navigate(sheet: .companyEditSuggestion(company: viewModel.company, onSubmit: {
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
        ProgressButton(action: { await viewModel.verifyCompany(isVerified: true) }, label: {
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
