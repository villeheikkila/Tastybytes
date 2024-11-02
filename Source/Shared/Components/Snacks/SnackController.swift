import SwiftUI

@MainActor
@Observable
final class SnackController {
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
