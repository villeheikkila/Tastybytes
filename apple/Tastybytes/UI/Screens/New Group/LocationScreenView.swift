import Charts
import PhotosUI
import SwiftUI

struct LocationScreenView: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var profileManager: ProfileManager
  @StateObject private var viewModel: ViewModel
  @State private var scrollToTop: Int = 0
  @State private var resetView: Int = 0

  init(_ client: Client, location: Location) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, location: location))
  }

  var body: some View {
    CheckInListView(
      viewModel.client,
      fetcher: .location(viewModel.location),
      scrollToTop: $scrollToTop,
      resetView: $resetView,
      onRefresh: {
        viewModel.getSummary()
      }
    ) {
      if let summary = viewModel.summary, summary.averageRating != nil {
        Section {
          SummaryView(summary: summary)
        }
      }
    }
    .navigationTitle(viewModel.location.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      toolbarContent
    }
    .confirmationDialog("Delete Location Confirmation",
                        isPresented: $viewModel.showDeleteLocationConfirmation,
                        presenting: viewModel.location) { presenting in
      Button(
        "Delete \(presenting.name) location",
        role: .destructive,
        action: { viewModel.deleteLocation(presenting, onDelete: {
          router.reset()
        })
        }
      )
    }
    .task {
      viewModel.getSummary()
    }
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Menu {
        ShareLink("Share", item: NavigatablePath.location(id: viewModel.location.id).url)
        if profileManager.hasPermission(.canDeleteProducts) {
          Button(action: {
            viewModel.showDeleteLocationConfirmation.toggle()
          }) {
            Label("Delete", systemImage: "trash.fill")
          }
        }
      } label: {
        Image(systemName: "ellipsis")
      }
    }
  }
}
