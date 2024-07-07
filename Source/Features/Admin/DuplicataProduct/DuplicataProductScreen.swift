import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct DuplicateProductScreen: View {
    private let logger = Logger(category: "DuplicateProductScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var state: ScreenState = .loading
    @State private var duplicateProductSuggestions = [ProductDuplicateSuggestion]()
    @State private var deleteProduct: Product.Joined?

    let filter: MarkedAsDuplicateFilter

    var body: some View {
        List(duplicateProductSuggestions) { duplicateProductSuggestion in
            DuplicateProductScreeRow(duplicateProductSuggestion: duplicateProductSuggestion)
        }
        .listStyle(.plain)
        .overlay {
            if state == .populated, duplicateProductSuggestions.isEmpty {
                ContentUnavailableView("admin.duplicates.empty.title", systemImage: "tray")
            } else {
                ScreenStateOverlayView(state: state, errorDescription: "") {
                    await loadDuplicateProducts()
                }
            }
        }
        .refreshable {
            await loadDuplicateProducts(withHaptics: true)
        }
        .navigationBarTitle("admin.duplicates.title")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadDuplicateProducts()
        }
    }

    func loadDuplicateProducts(withHaptics: Bool = false) async {
        if withHaptics {
            feedbackEnvironmentModel.trigger(.impact(intensity: .low))
        }
        switch await repository.product.getMarkedAsDuplicateProducts(filter: filter) {
        case let .success(duplicateProductSuggestions):
            withAnimation {
                state = .populated
                self.duplicateProductSuggestions = duplicateProductSuggestions
            }
            if withHaptics {
                feedbackEnvironmentModel.trigger(.notification(.success))
            }

        case let .failure(error):
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Fetching duplicate products failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct DuplicateProductScreeRow: View {
    @State private var showDeleteProductConfirmation = false
    let duplicateProductSuggestion: ProductDuplicateSuggestion

    var body: some View {
        VStack {
            HStack {
                Avatar(profile: duplicateProductSuggestion.createdBy)
                    .avatarSize(.small)
                Text(duplicateProductSuggestion.createdBy.preferredName).font(.caption).bold()
                Spacer()
                Text(duplicateProductSuggestion.createdAt.formatted(.customRelativetime)).font(.caption).bold()
            }
            ProductEntityView(product: duplicateProductSuggestion.product)
                .contentShape(.rect)
                .accessibilityAddTraits(.isLink)
                .openOnTap(.screen(.product(duplicateProductSuggestion.product)))
            ProductEntityView(product: duplicateProductSuggestion.duplicate)
                .contentShape(.rect)
                .accessibilityAddTraits(.isLink)
                .openOnTap(.screen(.product(duplicateProductSuggestion.duplicate)))
        }
    }
}
