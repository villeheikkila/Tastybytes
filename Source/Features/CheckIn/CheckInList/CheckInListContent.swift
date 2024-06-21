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
    @Environment(Router.self) private var router
    @Binding var checkIns: [CheckIn]
    let loadedFrom: CheckInCard.LoadedFrom
    let onCheckInUpdate: @MainActor (_ checkIn: CheckIn) async -> Void
    let onCreateCheckIn: @MainActor (_ checkIn: CheckIn) async -> Void
    let onLoadMore: () -> Void

    var body: some View {
        ForEach(checkIns) { checkIn in
            CheckInListCard(
                checkIn: checkIn,
                loadedFrom: loadedFrom,
                onUpdate: onCheckInUpdate,
                onDelete: deleteCheckIn,
                onCreate: onCreateCheckIn
            )
            .listRowSeparator(.visible, edges: .bottom)
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                -50
            }
            .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
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
            router.openAlert(.init(title: "checkIn.delete.failure.alert"))
            logger.error("Deleting check-in failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
