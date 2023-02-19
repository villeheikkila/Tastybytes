import SwiftUI

struct BottomOverlay<RootView: View>: View {
  let view: () -> RootView

  init(
    @ViewBuilder view: @escaping () -> RootView
  ) {
    self.view = view
  }

  var body: some View {
    VStack {
      Spacer()
      HStack {
        Spacer()
        VStack {
          view()
        }
        .padding([.top, .bottom], 10)
        Spacer()
      }
      .background(.ultraThinMaterial)
    }
  }
}
