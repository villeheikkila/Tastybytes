import SwiftUI

struct ProfileStatisticsView: View {
  let logger = getLogger(category: "ProfileStatisticsView")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @State private var categoryStatistics = [CategoryStatistics]()

  let profile: Profile

  var body: some View {
    List {
      Section {
        ForEach(categoryStatistics) { category in
          DisclosureGroup(content: {
            SubcategoryStatisticsView(profile: profile, category: category)
          }, label: {
            HStack {
              CategoryNameView(category: category, withBorder: false)
              Spacer()
              Text(String(category.count)).font(.caption).bold()
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 32))
          })
        }
      } header: {
        if !categoryStatistics.isEmpty {
          Text("Category")
        }
      }
      .headerProminence(.increased)
    }
    .listStyle(.insetGrouped)
    .navigationTitle("Statistics")
    .refreshable {
      await loadStatistics()
    }
    .task {
      await loadStatistics()
    }
  }

  func loadStatistics() async {
    switch await repository.profile.getCategoryStatistics(userId: profile.id) {
    case let .success(categoryStatistics):
      withAnimation {
        self.categoryStatistics = categoryStatistics
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed loading category statistics: \(error.localizedDescription)")
    }
  }
}

struct SubcategoryStatisticsView: View {
  let logger = getLogger(category: "SubcategoryStatistics")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @State private var subcategoryStatistics = [SubcategoryStatistics]()
  @State private var isLoading = false

  let profile: Profile
  let category: CategoryStatistics

  var body: some View {
    Section {
      if isLoading {
        ProgressView()
          .frame(maxWidth: .infinity)
          .padding([.top, .bottom], 8)
      }
      ForEach(subcategoryStatistics) { subcategory in
        HStack {
          Text(subcategory.name).font(.caption).bold()
          Spacer()
          Text(String(subcategory.count)).font(.caption).bold()
        }
      }
    } header: {
      Label("Subcategories", systemImage: "tag").font(.caption).bold()
    }
    .task {
      await loadSubcategoryStatistics()
    }
  }

  func loadSubcategoryStatistics() async {
    guard isLoading == false, subcategoryStatistics.isEmpty else { return }
    isLoading = true
    switch await repository.profile.getSubcategoryStatistics(userId: profile.id, categoryId: category.id) {
    case let .success(subcategoryStatistics):
      withAnimation {
        self.subcategoryStatistics = subcategoryStatistics
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed loading subcategory statistics: \(error.localizedDescription)")
    }
    isLoading = false
  }
}
