import Models
import SwiftUI

struct FlavorView: View {
    let flavor: Flavor.Saved

    var body: some View {
        Text(flavor.label)
    }
}
