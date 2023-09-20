import SwiftUI

public struct MaterialOverlay<RootView: View>: View {
    public enum Alignment {
        case top, bottom
    }

    let view: RootView
    let alignment: Alignment

    public init(
        alignment: Alignment,
        @ViewBuilder view: @escaping () -> RootView
    ) {
        self.view = view()
        self.alignment = alignment
    }

    public var body: some View {
        VStack {
            if alignment == .bottom {
                Spacer()
            }

            HStack {
                Spacer()
                VStack {
                    view
                }
                .padding([.top, .bottom], 10)
                Spacer()
            }
            .background(.ultraThinMaterial)

            if alignment == .top {
                Spacer()
            }
        }
    }
}
