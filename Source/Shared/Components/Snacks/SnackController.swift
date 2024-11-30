import SwiftUI

@MainActor
@Observable
final class SnackController {
    private var timeoutTasks: [UUID: Task<Void, Never>] = [:]

    var snacks: [Snack] = [] {
        didSet {
            if snacks.isEmpty {
                showOverview = false
            }
        }
    }

    var showOverview = false

    func open(_ snack: Snack) {
        withAnimation(.bouncy) {
            snacks.append(snack)
        }
        if let timeout = snack.timeout {
            let task = Task {
                try? await Task.sleep(for: .seconds(timeout))
                remove(snack.id)
            }
            timeoutTasks[snack.id] = task
        }
    }

    func remove(_ id: UUID) {
        if let index = snacks.firstIndex(where: { $0.id == id }) {
            snacks[index].isDeleting = true
            withAnimation(.bouncy) {
                snacks.removeAll(where: { $0.id == id })
            }
        }
    }
}
