import Components

import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInListContentView: View {
    private let logger = Logger(category: "CheckInListContentView")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @State private var loadingCheckInsOnAppearTask: Task<Void, Error>?
    @Binding var checkIns: [CheckIn.Joined]
    let onCreateCheckIn: ((_ checkIn: CheckIn.Joined) async -> Void)?
    let onLoadMore: () async -> Void

    init(
        checkIns: Binding<[CheckIn.Joined]>,
        onCreateCheckIn: ((_: CheckIn.Joined) async -> Void)? = nil,
        onLoadMore: @MainActor @Sendable @escaping () async -> Void
    ) {
        _checkIns = checkIns
        self.onCreateCheckIn = onCreateCheckIn
        self.onLoadMore = onLoadMore
    }

    var body: some View {
        ForEach(checkIns) { checkIn in
            CheckInListCardView(
                checkIn: checkIn,
                onUpdate: { checkIn in
                    checkIns = checkIns.replacingWithId(checkIn.id, with: checkIn)
                },
                onDelete: deleteCheckIn,
                onCreate: { checkIn in
                    checkIns.insert(checkIn, at: 0)
                    if let onCreateCheckIn {
                        await onCreateCheckIn(checkIn)
                    }
                }
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
                    guard loadingCheckInsOnAppearTask == nil else { return }
                    loadingCheckInsOnAppearTask = Task {
                        defer { loadingCheckInsOnAppearTask = nil }
                        logger.info("Loading more items invoked")
                        await onLoadMore()
                    }
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
