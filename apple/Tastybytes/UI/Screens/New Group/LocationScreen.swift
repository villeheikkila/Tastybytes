import Charts
import PhotosUI
import SwiftUI

struct LocationScreen: View {
  private let logger = getLogger(category: "LocationScreen")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var profileManager: ProfileManager
  @State private var scrollToTop: Int = 0
  @State private var summary: Summary?
  @State private var showDeleteLocationConfirmation = false

  let location: Location

  var body: some View {
    CheckInListView(
      fetcher: .location(location),
      scrollToTop: $scrollToTop,
      onRefresh: { await getSummary() },
      emptyView: {},
      header: {
        if let summary, summary.averageRating != nil {
          Section {
            SummaryView(summary: summary)
          }
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
        }
      }
    )
    .navigationTitle(location.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      toolbarContent
    }
    .confirmationDialog(
      "Are you sure you want to delete the location, the location information for check-ins with this location will be permanently lost",
      isPresented: $showDeleteLocationConfirmation,
      titleVisibility: .visible,
      presenting: location
    ) { presenting in
      ProgressButton("Delete \(presenting.name)", role: .destructive, action: { await deleteLocation(presenting) })
    }
    .task {
      await getSummary()
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Menu {
        ShareLink("Share", item: NavigatablePath.location(id: location.id).url)
        Divider()

        if profileManager.hasRole(.admin) {
          Menu {
            if profileManager.hasPermission(.canMergeLocations) {
              RouterLink(sheet: .mergeLocationSheet(location: location), label: {
                Label("Merge to...", systemImage: "doc.on.doc")
              })
            }
            if profileManager.hasPermission(.canDeleteProducts) {
              Button(
                "Delete",
                systemImage: "trash.fill",
                role: .destructive,
                action: { showDeleteLocationConfirmation.toggle() }
              )
            }
          } label: {
            Label("Admin", systemImage: "gear")
              .labelStyle(.iconOnly)
          }
        }
      } label: {
        Label("Options menu", systemImage: "ellipsis")
          .labelStyle(.iconOnly)
      }
    }
  }

  func getSummary() async {
    switch await repository.location.getSummaryById(id: location.id) {
    case let .success(summary):
      withAnimation {
        self.summary = summary
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to get summary: \(error.localizedDescription)")
    }
  }

  func deleteLocation(_ location: Location) async {
    switch await repository.location.delete(id: location.id) {
    case .success:
      router.reset()
      feedbackManager.trigger(.notification(.success))
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to delete location: \(error.localizedDescription)")
    }
  }
}
