import SwiftUI

struct ProductFilterOverlayView: View {
  let filters: Product.Filter

  var body: some View {
    HStack {
      if let category = filters.category {
        Text(category.label).bold()
      }
      if filters.category != nil, filters.subcategory != nil {
        Image(systemName: "arrowtriangle.forward")
          .accessibility(hidden: true)
      }
      if let subcategory = filters.subcategory {
        Text(subcategory.label).bold()
      }
    }
    if let sortBy = filters.sortBy {
      Text("Sorted by \(sortBy.label)").bold()
    }

    if filters.onlyNonCheckedIn {
      Text("Show only products you haven't tried").fontWeight(.medium)
    }
  }
}
