import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInListContent: View {
    private let logger = Logger(category: "CheckInListContent")
    @Environment(\.repository) private var repository
    let loadedFrom: CheckInCard.LoadedFrom
    @Binding var checkIns: [CheckIn]
    @Binding var isLoading: Bool
    @Binding var isRefreshing: Bool
    @Binding var alertError: AlertError?
    let onLoadMore: () -> Void

    var body: some View {
        LazyVStack {
            ForEach(checkIns) { checkIn in
                CheckInListCard(
                    checkIn: checkIn,
                    loadedFrom: loadedFrom,
                    onUpdate: onCheckInUpdate,
                    onDelete: deleteCheckIn
                )
                .id(checkIn.id)
                .onAppear {
                    if checkIn == checkIns.last, isLoading != true {
                        onLoadMore()
                    }
                }
            }
            ProgressView()
                .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                .opacity(isLoading && !isRefreshing ? 1 : 0)
        }
        .scrollTargetLayout()
    }

    func deleteCheckIn(_ checkIn: CheckIn) async {
        switch await repository.checkIn.delete(id: checkIn.id) {
        case .success:
            withAnimation {
                checkIns.remove(object: checkIn)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = AlertError(title: "Error occured while trying to delete a check-in. Please try again!")
            logger.error("Deleting check-in failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func onCheckInUpdate(_ checkIn: CheckIn) {
        guard let index = checkIns.firstIndex(where: { $0.id == checkIn.id }) else { return }
        checkIns[index] = checkIn
    }
}
