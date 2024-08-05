import Components
import Models
import SwiftUI

struct FlavorsView: View {
    let flavors: [Flavor.Saved]

    var body: some View {
        WStack(alignment: .leading, horizontalSpacing: 4, verticalSpacing: 4) {
            ForEach(flavors) { flavor in
                FlavorView(flavor: flavor)
            }
        }
        .flavorStyle(.chip)
    }
}
