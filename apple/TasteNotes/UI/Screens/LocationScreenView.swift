import Charts
import GoTrue
import PhotosUI
import SwiftUI

struct LocationScreenView: View {
  @StateObject private var viewModel = ViewModel()
  @State private var scrollToTop: Int = 0

  let location: Location

  var body: some View {
    InfiniteScrollView(data: $viewModel.checkIns, isLoading: $viewModel.isLoading, scrollToTop: $scrollToTop,
                       loadMore: { viewModel.fetchMoreCheckIns(locationId: location.id) },
                       refresh: {
                         viewModel.refresh(locationId: location.id)
                       },
                       content: {
                         CheckInCardView(checkIn: $0,
                                         loadedFrom: .location(location),
                                         onDelete: { checkIn in viewModel.onCheckInDelete(checkIn: checkIn)
                                         },
                                         onUpdate: { checkIn in viewModel.onCheckInUpdate(checkIn: checkIn) })
                       }, header: {})
      .navigationTitle(location.name)
      .navigationBarTitleDisplayMode(.inline)
  }
}

extension LocationScreenView {
  @MainActor class ViewModel: ObservableObject {
    @Published var checkIns = [CheckIn]()
    @Published var profileSummary: ProfileSummary?
    @Published var isLoading = false
    @Published var selectedItem: PhotosPickerItem?

    private let pageSize = 10
    private var page = 0

    func refresh(locationId: UUID) {
      page = 0
      checkIns = []
      fetchMoreCheckIns(locationId: locationId)
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

    func fetchMoreCheckIns(locationId: UUID) {
      let (from, to) = getPagination(page: page, size: pageSize)

      Task {
        await MainActor.run {
          self.isLoading = true
        }

        switch await repository.checkIn.getByLocation(locationId: locationId, from: from, to: to) {
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
