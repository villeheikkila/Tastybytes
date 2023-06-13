import SwiftUI

struct Spacing: View {
    var height: CGFloat?
    var width: CGFloat?

    var body: some View {
        if let height {
            Color.clear.frame(height: height)
        } else if let width {
            Color.clear.frame(width: width)
        } else {
            Spacer()
        }
    }
}
