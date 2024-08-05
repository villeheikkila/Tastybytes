import Models
import SwiftUI
import Components

struct FlavorsView: View {
    let flavors: [Flavor.Saved]

     var body: some View {
        WrappingHStack(alignment: .leading, horizontalSpacing: 4, verticalSpacing: 4) {
            ForEach(flavors) { flavor in
                ChipView(title: flavor.label)
            }
        }
    }
}
