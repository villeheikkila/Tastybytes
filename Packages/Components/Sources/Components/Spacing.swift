import SwiftUI

public struct Spacing: View {
    var height: CGFloat?
    var width: CGFloat?

    public var body: some View {
        if let height {
            Color.clear.frame(height: height)
        } else if let width {
            Color.clear.frame(width: width)
        } else {
            Spacer()
        }
    }
}
