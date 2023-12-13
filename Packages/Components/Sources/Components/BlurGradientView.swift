import SwiftUI

public struct BlurGradientView<TopContent: View, BottomContent: View>: View {
    let position: Position
    let height: CGFloat?
    @ViewBuilder var topContent: () -> TopContent
    @ViewBuilder var bottomContent: () -> BottomContent

    public init(
        position: Position = .bottom,
        height: CGFloat?,
        topContent: @escaping () -> TopContent,
        bottomContent: @escaping () -> BottomContent
    ) {
        self.position = position
        self.topContent = topContent
        self.bottomContent = bottomContent
        self.height = height
    }

    var colors: [Color] {
        [0, 0.1, 0.5, 0.75, 1, 1, 1, 1].map {
            Color.black.opacity($0)
        }
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            topContent()
            Rectangle()
                .fill(Color.clear)
                .background(Material.thin)
                .mask {
                    LinearGradient(colors: colors,
                                   startPoint: position.start,
                                   endPoint: position.end)
                }
                .frame(height: 300)
            bottomContent()
        }
    }
}

public extension BlurGradientView {
    enum Position {
        case bottom, top, leading, trailing

        var start: UnitPoint {
            switch self {
            case .bottom:
                .top
            case .top:
                .bottom
            case .leading:
                .trailing
            case .trailing:
                .leading
            }
        }

        var end: UnitPoint {
            switch self {
            case .bottom:
                .bottom
            case .top:
                .top
            case .leading:
                .leading
            case .trailing:
                .trailing
            }
        }
    }
}
