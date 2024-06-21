import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct DuplicateProductScreen: View {
    private let logger = Logger(category: "ProductVerificationScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var duplicateProductSuggestions = [ProductDuplicateSuggestion]()
    @State private var deleteProduct: Product.Joined?

    var body: some View {
        List(duplicateProductSuggestions) { duplicateProductSuggestion in
            DuplicateProductScreeRow(duplicateProductSuggestion: duplicateProductSuggestion)
        }
        .listStyle(.plain)
        .refreshable {
            await loadDuplicateProducts(withHaptics: true)
        }
        .navigationBarTitle("admin.duplicates.title")
        .task {
            await loadDuplicateProducts()
        }
    }

    func loadDuplicateProducts(withHaptics: Bool = false) async {
        if withHaptics {
            feedbackEnvironmentModel.trigger(.impact(intensity: .low))
        }
        switch await repository.product.getMarkedAsDuplicateProducts() {
        case let .success(duplicateProductSuggestions):
            withAnimation {
                self.duplicateProductSuggestions = duplicateProductSuggestions
            }
            if withHaptics {
                feedbackEnvironmentModel.trigger(.notification(.success))
            }

        case let .failure(error):
            guard !error.isCancelled else { return }
            router.openAlert(.init())
            logger.error("Fetching duplicate products failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct DuplicateProductScreeRow: View {
    @Environment(Router.self) private var router
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
            ProductItemView(product: duplicateProductSuggestion.product)
                .contentShape(Rectangle())
                .accessibilityAddTraits(.isLink)
                .onTapGesture {
                    router.navigate(screen: .product(duplicateProductSuggestion.product))
                }
            ProductItemView(product: duplicateProductSuggestion.duplicate)
                .contentShape(Rectangle())
                .accessibilityAddTraits(.isLink)
                .onTapGesture {
                    router.navigate(screen: .product(duplicateProductSuggestion.duplicate))
                }
        }
    }
}
