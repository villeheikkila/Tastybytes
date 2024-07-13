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
            DuplicateProductScreeRowView(duplicateProductSuggestion: duplicateProductSuggestion, onDelete: deleteProductSuggestion)
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
        do {
            let duplicateProductSuggestions = try await repository.product.getMarkedAsDuplicateProducts(filter: filter)
            withAnimation {
                state = .populated
                self.duplicateProductSuggestions = duplicateProductSuggestions
            }
            if withHaptics {
                feedbackEnvironmentModel.trigger(.notification(.success))
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Fetching duplicate products failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteProductSuggestion(_ duplicateProductSuggestion: ProductDuplicateSuggestion) async {
        do { try await repository.product.deleteProductDuplicateSuggestion(duplicateProductSuggestion)
            withAnimation {
                duplicateProductSuggestions = duplicateProductSuggestions.removing(duplicateProductSuggestion)
            }
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Delete product duplicate suggestion. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct DuplicateProductScreeRowView: View {
    @State private var showDeleteSuggestionConfirmation = false
    let duplicateProductSuggestion: ProductDuplicateSuggestion

    let onDelete: (_ suggestion: ProductDuplicateSuggestion) async -> Void

    var body: some View {
        VStack {
            HStack {
                Avatar(profile: duplicateProductSuggestion.createdBy)
                    .avatarSize(.small)
                Text(duplicateProductSuggestion.createdBy.preferredName).font(.caption).bold()
                Spacer()
                Text(duplicateProductSuggestion.createdAt.formatted(.customRelativetime)).font(.caption).bold()
            }
            RouterLink(open: .screen(.product(duplicateProductSuggestion.product))) {
                ProductEntityView(product: duplicateProductSuggestion.product)
            }
            RouterLink(open: .screen(.product(duplicateProductSuggestion.duplicate))) {
                ProductEntityView(product: duplicateProductSuggestion.duplicate)
            }
        }
        .swipeActions {
            Button("labels.delete", systemImage: "trash") {
                showDeleteSuggestionConfirmation = true
            }
            .tint(.red)
        }
        .confirmationDialog(
            "product.admin.editSuggestion.delete.description",
            isPresented: $showDeleteSuggestionConfirmation,
            titleVisibility: .visible,
            presenting: duplicateProductSuggestion
        ) { presenting in
            AsyncButton(
                "product.admin.editSuggestion.delete.label",
                action: {
                    await onDelete(presenting)
                }
            )
            .tint(.green)
        }
    }
}
