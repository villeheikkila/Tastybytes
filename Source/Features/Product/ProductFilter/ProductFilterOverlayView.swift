import Models
import SwiftUI

struct ProductFilterOverlayView: View {
    let filters: Product.Filter
    let onReset: () -> Void

    var body: some View {
        HStack {
            VStack {
                HStack {
                    if let category = filters.category {
                        CategoryView(category: category).bold()
                    }
                    if filters.category != nil, filters.subcategory != nil {
                        Image(systemName: "arrowtriangle.forward")
                            .accessibility(hidden: true)
                    }
                    if let subcategory = filters.subcategory {
                        SubcategoryView(subcategory: subcategory).bold()
                    }
                    Spacer()
                }
                if let sortBy = filters.sortBy {
                    HStack {
                        Text(sortBy.label).bold()
                        Spacer()
                    }
                }

                if filters.onlyNonCheckedIn {
                    HStack {
                        Text("product.filter.overlay.showingOnlyNotHad").fontWeight(.medium)
                        Spacer()
                    }
                }
            }
            Spacer()
            CloseButtonView {
                onReset()
            }
        }
        .padding(4)
        .background(.ultraThinMaterial)
    }
}
