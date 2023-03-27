import SwiftUI

struct ProfileStatisticsView: View {
  @StateObject private var viewModel: ViewModel

  init(_ client: Client, profile: Profile) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, profile: profile))
  }

  var body: some View {
    List {
      Section {
        ForEach(viewModel.categoryStatistics) { category in
          HStack {
            CategoryNameView(category: category)
            Spacer()
            Text("(\(category.count))").font(.caption).bold()
          }
        }
      } header: {
        Text("Category")
      }.headerProminence(.increased)
    }
    .refreshable {
      await viewModel.loadStatistics()
    }
    .task {
      await viewModel.loadStatistics()
    }
    .navigationTitle("Statistics")
  }
}

extension ProfileStatisticsView {
  @MainActor class ViewModel: ObservableObject {
    let logger = getLogger(category: "ProfileStatisticsView")
    let client: Client
    let profile: Profile

    @Published var categoryStatistics = [CategoryStatistics]()

    init(_ client: Client, profile: Profile) {
      self.client = client
      self.profile = profile
    }

    func loadStatistics() async {
      switch await client.profile.getCategoryStatistics(userId: profile.id) {
      case let .success(categoryStatistics):
        withAnimation {
          self.categoryStatistics = categoryStatistics
        }
      case let .failure(error):
        logger.error("failed loading category statistics: \(error.localizedDescription)")
      }
    }
  }
}
