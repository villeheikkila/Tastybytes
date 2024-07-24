import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInListContentView: View {
    private let logger = Logger(category: "CheckInListContentView")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Binding var checkIns: [CheckIn.Joined]
    let onCheckInUpdate: (_ checkIn: CheckIn.Joined) async -> Void
    let onCreateCheckIn: (_ checkIn: CheckIn.Joined) async -> Void
    let onLoadMore: () -> Void

    var body: some View {
        ForEach(checkIns) { checkIn in
            CheckInListCardView(
                checkIn: checkIn,
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
                if let index = checkIns.firstIndex(of: checkIn),
                   index == checkIns.count - 8
                {
                    onLoadMore()
                }
            }
        }
    }

    private func deleteCheckIn(_ checkIn: CheckIn.Joined) async {
        do {
            try await repository.checkIn.delete(id: checkIn.id)
            checkIns.remove(object: checkIn)
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init(title: "checkIn.delete.failure.alert")))
            logger.error("Deleting check-in failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
