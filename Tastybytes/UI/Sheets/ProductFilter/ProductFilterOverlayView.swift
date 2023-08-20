import Model
import SwiftUI

struct ProductFilterOverlayView: View {
    let filters: Product.Filter
    let onReset: () -> Void

    var body: some View {
        VStack {
            Spacer()

            HStack {
                VStack {
                    HStack {
                        if let category = filters.category {
                            Text(category.name).bold()
                        }
                        if filters.category != nil, filters.subcategory != nil {
                            Image(systemSymbol: .arrowtriangleForward)
                                .accessibility(hidden: true)
                        }
                        if let subcategory = filters.subcategory {
                            Text(subcategory.name).bold()
                        }
                        Spacer()
                    }
                    if let sortBy = filters.sortBy {
                        HStack {
                            Text("Sorted by \(sortBy.label)").bold()
                            Spacer()
                        }
                    }

                    if filters.onlyNonCheckedIn {
                        HStack {
                            Text("Showing only products you haven't tried").fontWeight(.medium)
                            Spacer()
                        }
                    }
                }
                Spacer()
                Button("Reset filter", systemSymbol: .xCircle, action: { onReset() })
                    .labelStyle(.iconOnly)
                    .imageScale(.large)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}
