import Components

import Extensions
import Logging
import Models
import Repositories
import SwiftUI

struct DuplicateProductSuggestionView: View {
    let editSuggestion: Product.EditSuggestion

    var body: some View {
        VStack {
            HStack {
                AvatarView(profile: editSuggestion.createdBy)
                    .avatarSize(.small)
                Text(editSuggestion.createdBy.preferredName).font(.caption).bold()
                Spacer()
                Text(editSuggestion.createdAt.formatted(.customRelativetime)).font(.caption).bold()
            }
            RouterLink(open: .screen(.product(editSuggestion.product.id))) {
                ProductView(product: editSuggestion.product)
            }
            if let duplicateOf = editSuggestion.duplicateOf {
                RouterLink(open: .screen(.product(duplicateOf.id))) {
                    ProductView(product: duplicateOf)
                }
            }
        }
    }
}
