import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ProfileStatisticsUniqueByCategoryScreen: View {
    private let logger = Logger(category: "ProfileStatisticsView")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var categoryStatistics = [CategoryStatistics]()
    @State private var alertError: AlertError?

    let profile: Profile

    var body: some View {
        List(categoryStatistics) { category in
            ProfileStatisticsUniqueByCategoryRow(profile: profile, category: category)
        }
        .listStyle(.plain)
        .navigationTitle("profileStatistics.uniqueByCategory.navigationTitle")
        .refreshable {
            await loadStatistics()
        }
        .alertError($alertError)
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
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed loading category statistics. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct ProfileStatisticsUniqueByCategoryRow: View {
    let profile: Profile
    let category: CategoryStatistics

    var body: some View {
        DisclosureGroup(content: {
            SubcategoryStatisticsView(profile: profile, category: category)
        }, label: {
            HStack {
                CategoryNameView(category: category, withBorder: false)
                Spacer()
                Text(category.count.formatted()).font(.caption).bold()
            }
        })
    }
}

struct SubcategoryStatisticsView: View {
    private let logger = Logger(category: "SubcategoryStatisticsView")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var subcategoryStatistics = [SubcategoryStatistics]()
    @State private var isLoading = false
    @State private var alertError: AlertError?

    let profile: Profile
    let category: CategoryStatistics

    var body: some View {
        Section {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            } else {
                SubcategoryStatisticsRow(profile: profile, category: category.category, subcategory: nil)
                ForEach(subcategoryStatistics) { subcategory in
                    SubcategoryStatisticsRow(profile: profile, category: category.category, subcategory: subcategory)
                }
            }
        }
        .alertError($alertError)
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
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed loading subcategory statistics. Error: \(error) (\(#file):\(#line))")
        }
        isLoading = false
    }
}

struct SubcategoryStatisticsRow: View {
    let profile: Profile
    let category: Models.Category
    let subcategory: SubcategoryStatistics?

    var body: some View {
        RouterLink(screen: .profileProductsByFilter(
            profile,
            .init(
                category: category,
                subcategory: subcategory?.subcategory,
                sortBy: .highestRated
            )
        )) {
            if let subcategory {
                HStack {
                    Text(subcategory.name)
                    Spacer()
                    Text(subcategory.count.formatted())
                }
                .font(.caption)
            } else {
                Text("subcategoryStatistics.all.open")
                    .foregroundColor(Color.primary)
                    .font(.caption)
                    .bold()
            }
        }
    }
}
