import Models
import SwiftUI

public struct FlavorsView: View {
    let flavors: [Flavor]

    public init(flavors: [Flavor]) {
        self.flavors = flavors
    }

    public var body: some View {
        WrappingHStack(alignment: .leading, horizontalSpacing: 4, verticalSpacing: 4) {
            ForEach(flavors) { flavor in
                ChipView(title: flavor.label)
            }
        }
    }
}
