import Charts
import PhotosUI
import SwiftUI

struct LocationScreen: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var profileManager: ProfileManager
  @StateObject private var viewModel: ViewModel
  @State private var scrollToTop: Int = 0

  init(_ client: Client, location: Location) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, location: location))
  }

  var body: some View {
    CheckInListView(
      viewModel.client,
      fetcher: .location(viewModel.location),
      scrollToTop: $scrollToTop,
      onRefresh: { await viewModel.getSummary() },
      header: {
        if let summary = viewModel.summary, summary.averageRating != nil {
          Section {
            SummaryView(summary: summary)
          }
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
        }
      }
    )
    .navigationTitle(viewModel.location.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      toolbarContent
    }
    .confirmationDialog(
      "Are you sure you want to delete the location, the location information for check-ins with this location will be permanently lost",
      isPresented: $viewModel.showDeleteLocationConfirmation,
      titleVisibility: .visible,
      presenting: viewModel.location
    ) { presenting in
      ProgressButton(
        "Delete \(presenting.name)",
        role: .destructive,
        action: {
          await viewModel.deleteLocation(presenting, onDelete: {
            router.reset()
          })
          hapticManager.trigger(.notification(.success))
        }
      )
    }
    .task {
      await viewModel.getSummary()
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Menu {
        ShareLink("Share", item: NavigatablePath.location(id: viewModel.location.id).url)
        if profileManager.hasPermission(.canDeleteProducts) {
          Button(
            "Delete",
            systemImage: "trash.fill",
            role: .destructive,
            action: { viewModel.showDeleteLocationConfirmation.toggle() }
          )
        }
      } label: {
        Label("Options menu", systemImage: "ellipsis")
          .labelStyle(.iconOnly)
      }
    }
  }
}
