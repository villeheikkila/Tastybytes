import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct CheckInListContent: View {
    private let logger = Logger(category: "CheckInList")
    @Environment(Repository.self) private var repository
    @Binding var checkIns: [CheckIn]
    @Binding var alertError: AlertError?
    let loadedFrom: CheckInCard.LoadedFrom
    let onLoadMore: () -> Void

    var body: some View {
        ForEach(checkIns) { checkIn in
            CheckInListCard(
                checkIn: checkIn,
                loadedFrom: loadedFrom,
                onUpdate: onCheckInUpdate,
                onDelete: deleteCheckIn
            )
            .id(checkIn.id)
            .onAppear {
                if checkIn == checkIns.last {
                    onLoadMore()
                }
            }
        }
    }

    func deleteCheckIn(_ checkIn: CheckIn) async {
        switch await repository.checkIn.delete(id: checkIn.id) {
        case .success:
            withAnimation {
                checkIns.remove(object: checkIn)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = AlertError(title: "checkIn.delete.failure.alert")
            logger.error("Deleting check-in failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func onCheckInUpdate(_ checkIn: CheckIn) {
        guard let index = checkIns.firstIndex(where: { $0.id == checkIn.id }) else { return }
        checkIns[index] = checkIn
    }
}
