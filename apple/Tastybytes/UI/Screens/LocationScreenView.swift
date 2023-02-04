import Charts
import PhotosUI
import SwiftUI

struct LocationScreenView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var profileManager: ProfileManager
  @StateObject private var viewModel: ViewModel
  @State private var scrollToTop: Int = 0
  @State private var resetView: Int = 0

  init(location: Location) {
    _viewModel = StateObject(wrappedValue: ViewModel(location: location))
  }

  var body: some View {
    CheckInListView(
      fetcher: .location(viewModel.location),
      scrollToTop: $scrollToTop,
      resetView: $resetView,
      onRefresh: {}
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

extension LocationScreenView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "LocationScreenView")
    @Published var summary: Summary?
    @Published var showDeleteLocationConfirmation = false
    let location: Location

    init(location: Location) {
      self.location = location
    }

    func getSummary() {
      Task {
        switch await repository.location.getSummaryById(id: location.id) {
        case let .success(summary):
          withAnimation {
            self.summary = summary
          }
        case let .failure(error):
          print(error)
        }
      }
    }

    func deleteLocation(_ location: Location, onDelete: @escaping () -> Void) {
      Task {
        switch await repository.location.delete(id: location.id) {
        case .success:
          onDelete()
        case let .failure(error):
          print(error)
        }
      }
    }
  }
}
