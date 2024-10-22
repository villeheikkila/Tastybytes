import Components

import Extensions
import Models
import Logging
import Repositories
import SwiftUI

struct CheckInListContentView: View {
    private let logger = Logger(label: "CheckInListContentView")
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
                onUpdate: { updatedCheckIn in
                    if updatedCheckIn.product.id == checkIn.product.id {
                        checkIns = checkIns.replacingWithId(checkIn.id, with: checkIn)
                    } else {
                        checkIns = checkIns.removingWithId(updatedCheckIn.id)
                        try? await Task.sleep(for: .milliseconds(100))
                        router.open(.screen(.product(updatedCheckIn.product.id)))
                    }
                },
                onDelete: deleteCheckIn,
                onCreate: { checkIn in
                    checkIns = [checkIn] + checkIns
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
