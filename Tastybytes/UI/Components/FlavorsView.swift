import Model
import SwiftUI

struct FlavorsView: View {
    let flavors: [Flavor]

    var body: some View {
        WrappingHStack(alignment: .leading, horizontalSpacing: 4, verticalSpacing: 4) {
            ForEach(flavors) { flavor in
                ChipView(title: flavor.label)
            }
        }
    }
}
