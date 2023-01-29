import Charts
import PhotosUI
import SwiftUI

struct LocationScreenView: View {
  @StateObject private var viewModel: ViewModel
  @State private var scrollToTop: Int = 0

  init(location: Location) {
    _viewModel = StateObject(wrappedValue: ViewModel(location: location))
  }

  var body: some View {
    InfiniteScrollView(data: $viewModel.checkIns, isLoading: $viewModel.isLoading, scrollToTop: $scrollToTop,
                       loadMore: { viewModel.fetchMoreCheckIns() },
                       refresh: {
                         viewModel.refresh()
                       },
                       content: {
                         CheckInCardView(checkIn: $0,
                                         loadedFrom: .location(viewModel.location),
                                         onDelete: { checkIn in viewModel.onCheckInDelete(checkIn: checkIn)
                                         },
                                         onUpdate: { checkIn in viewModel.onCheckInUpdate(checkIn: checkIn) })
                       }, header: {
                         if let summary = viewModel.summary, summary.averageRating != nil {
                           Section {
                             SummaryView(summary: summary)
                           }
                         }
                       })
                       .navigationTitle(viewModel.location.name)
                       .navigationBarTitleDisplayMode(.inline)
                       .task {
                         viewModel.getSummary()
                       }
  }
}

extension LocationScreenView {
  @MainActor class ViewModel: ObservableObject {
    @Published var checkIns = [CheckIn]()
    @Published var profileSummary: ProfileSummary?
    @Published var summary: Summary?
    @Published var isLoading = false
    @Published var selectedItem: PhotosPickerItem?
    let location: Location

    init(location: Location) {
      self.location = location
    }

    private let pageSize = 10
    private var page = 0

    func refresh() {
      page = 0
      checkIns = []
      fetchMoreCheckIns()
    }

    func onCheckInUpdate(checkIn: CheckIn) {
      if let index = checkIns.firstIndex(where: { $0.id == checkIn.id }) {
        DispatchQueue.main.async {
          self.checkIns[index] = checkIn
        }
      }
    }

    func onCheckInDelete(checkIn: CheckIn) {
      checkIns.remove(object: checkIn)
    }

    func getSummary() {
      Task {
        switch await repository.location.getSummaryById(id: location.id) {
        case let .success(summary):
          await MainActor.run {
            self.summary = summary
          }
        case let .failure(error):
          print(error)
        }
      }
    }

    func fetchMoreCheckIns() {
      let (from, to) = getPagination(page: page, size: pageSize)

      Task {
        await MainActor.run {
          self.isLoading = true
        }

        switch await repository.checkIn.getByLocation(locationId: location.id, from: from, to: to) {
        case let .success(checkIns):
          await MainActor.run {
            self.checkIns.append(contentsOf: checkIns)
            self.page += 1
            self.isLoading = false
          }
        case let .failure(error):
          print(error)
        }
      }
    }
  }
}
