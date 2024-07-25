import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct DuplicateProductSuggestionEntityView: View {
    let editSuggestion: Product.EditSuggestion

    var body: some View {
        VStack {
            HStack {
                Avatar(profile: editSuggestion.createdBy)
                    .avatarSize(.small)
                Text(editSuggestion.createdBy.preferredName).font(.caption).bold()
                Spacer()
                Text(editSuggestion.createdAt.formatted(.customRelativetime)).font(.caption).bold()
            }
            RouterLink(open: .screen(.product(editSuggestion.product.id))) {
                ProductEntityView(product: editSuggestion.product)
            }
            if let duplicateOf = editSuggestion.duplicateOf {
                RouterLink(open: .screen(.product(duplicateOf.id))) {
                    ProductEntityView(product: duplicateOf)
                }
            }
        }
    }
}
