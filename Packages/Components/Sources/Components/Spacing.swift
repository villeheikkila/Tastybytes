import SwiftUI

@MainActor
public struct Spacing: View {
    var height: Double?
    var width: Double?

    public init(height: Double? = nil, width: Double? = nil) {
        self.height = height
        self.width = width
    }

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
