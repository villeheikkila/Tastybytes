import Models
import SwiftUI

struct FlavorEntityView: View {
    let flavor: Flavor.Saved

    var body: some View {
        Text(flavor.label)
    }
}
