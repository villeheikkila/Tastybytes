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
  }
}

extension ProfileStatisticsView {
  @MainActor class ViewModel: ObservableObject {
    let logger = getLogger(category: "ProfileStatisticsView")
    let client: Client
    let profile: Profile

    init(_ client: Client, profile: Profile) {
      self.client = client
      self.profile = profile
    }
  }
}
