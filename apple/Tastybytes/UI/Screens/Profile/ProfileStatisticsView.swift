import SwiftUI

struct ProfileStatisticsView: View {
  @StateObject private var viewModel: ViewModel

  init(_ client: Client, profile: Profile) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, profile: profile))
  }

  var body: some View {
    VStack {
      HStack {
        Text("Check")
      }
    }
    .navigationTitle("Statistics")
    .task {
      await viewModel.loadAllCheckIns()
    }
  }
}

extension ProfileStatisticsView {
  @MainActor class ViewModel: ObservableObject {
    let logger = getLogger(category: "ProfileStatisticsView")
    let client: Client
    let profile: Profile
    @Published var checkIns: [CheckIn] = []

    init(_ client: Client, profile: Profile) {
      self.client = client
      self.profile = profile
    }

    func loadAllCheckIns() async {
      switch await client.checkIn.getByProfileId(id: profile.id, queryType: .all) {
      case let .success(checkIns):
        withAnimation {
          self.checkIns = checkIns
        }
      case let .failure(error):
        logger.error("error occured while loading products: \(error)")
      }
    }
  }
}
