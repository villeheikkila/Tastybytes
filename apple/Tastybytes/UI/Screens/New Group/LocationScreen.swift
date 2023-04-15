import Charts
import PhotosUI
import SwiftUI

struct LocationScreen: View {
  private let logger = getLogger(category: "LocationScreen")
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var profileManager: ProfileManager
  @State private var scrollToTop: Int = 0
  @State private var summary: Summary?
  @State private var showDeleteLocationConfirmation = false

  let client: Client
  let location: Location

  var body: some View {
    CheckInListView(
      client,
      fetcher: .location(location),
      scrollToTop: $scrollToTop,
      onRefresh: { await getSummary() },
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
      ProgressButton(
        "Delete \(presenting.name)",
        role: .destructive,
        action: {
          await deleteLocation(presenting, onDelete: {
            router.reset()
          })
          hapticManager.trigger(.notification(.success))
        }
      )
    }
    .task {
      await getSummary()
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Menu {
        ShareLink("Share", item: NavigatablePath.location(id: location.id).url)
        if profileManager.hasPermission(.canDeleteProducts) {
          Button(
            "Delete",
            systemImage: "trash.fill",
            role: .destructive,
            action: { showDeleteLocationConfirmation.toggle() }
          )
        }
      } label: {
        Label("Options menu", systemImage: "ellipsis")
          .labelStyle(.iconOnly)
      }
    }
  }

  func getSummary() async {
    switch await client.location.getSummaryById(id: location.id) {
    case let .success(summary):
      withAnimation {
        self.summary = summary
      }
    case let .failure(error):
      logger.error("failed to get summary: \(error.localizedDescription)")
    }
  }

  func deleteLocation(_ location: Location, onDelete: @escaping () -> Void) async {
    switch await client.location.delete(id: location.id) {
    case .success:
      onDelete()
    case let .failure(error):
      logger.error("failed to delete location: \(error.localizedDescription)")
    }
  }
}
