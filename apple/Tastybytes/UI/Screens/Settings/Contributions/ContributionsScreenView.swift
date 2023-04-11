import SwiftUI

struct ContributionsScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    List {
      if let contributions = viewModel.contributions {
        HStack {
          Text("Products")
          Spacer()
          Text(String(contributions.products))
        }
        HStack {
          Text("Companies")
          Spacer()
          Text(String(contributions.companies))
        }
        HStack {
          Text("Brands")
          Spacer()
          Text(String(contributions.brands))
        }
        HStack {
          Text("Sub-brands")
          Spacer()
          Text(String(contributions.subBrands))
        }
        HStack {
          Text("Barcodes")
          Spacer()
          Text(String(contributions.barcodes))
        }
      }
    }
    .navigationTitle("Your Contributions")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      await viewModel.loadContributions(userId: profileManager.getId())
    }
  }
}
