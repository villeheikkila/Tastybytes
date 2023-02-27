import SwiftUI

struct MaterialOverlay<RootView: View>: View {
  enum Alignment {
    case top, bottom
  }

  let view: () -> RootView
  let alignment: Alignment

  init(
    alignment: Alignment,
    @ViewBuilder view: @escaping () -> RootView
  ) {
    self.view = view
    self.alignment = alignment
  }

  var body: some View {
    VStack {
      if alignment == .bottom {
        Spacer()
      }

      HStack {
        Spacer()
        VStack {
          view()
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
