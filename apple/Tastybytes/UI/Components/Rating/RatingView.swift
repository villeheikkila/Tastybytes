import SwiftUI

struct RatingView: View {
  @State private var starSize: CGSize = .zero
  @State private var controlSize: CGSize = .zero
  @GestureState private var dragging: Bool = false

  let rating: Double
  let type: StarType

  init(rating: Double, type: StarType = .large) {
    self.rating = rating
    self.type = type
  }

  var body: some View {
    ZStack {
      HStack {
        ForEach(0 ..< Int(rating), id: \.self) { _ in
          Image(systemName: "star.fill")
            .star(size: starSize, type: type)
            .foregroundColor(.yellow)
        }

        if rating != floor(rating) {
          Image(systemName: "star.leadinghalf.fill")
            .star(size: starSize, type: type)
            .foregroundColor(.yellow)
        }

        ForEach(0 ..< Int(Double(5) - rating), id: \.self) { _ in
          Image(systemName: "star")
            .star(size: starSize, type: type)
        }
      }
      .onPreferenceChange(StarSizeKey.self) { size in
        starSize = size
      }
      .onPreferenceChange(ControlSizeKey.self) { size in
        controlSize = size
      }
      Color.clear
        .frame(width: controlSize.width, height: controlSize.height)
        .contentShape(Rectangle())
    }
  }
}

enum StarType {
  case large, small
}

private extension Image {
  func star(size: CGSize, type: StarType) -> some View {
    font(type == StarType.large ? .title : .none)
      .background(
        Color.clear.preference(
          key: StarSizeKey.self,
          value: type == StarType.large ? CGSize(width: 26, height: 14) : CGSize(width: 12, height: 12)
        )
      )
      .frame(width: size.width, height: size.height)
  }
}

private protocol SizeKey: PreferenceKey {}
private extension SizeKey {
  static var defaultValue: CGSize { .zero }
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    let next = nextValue()
    value = CGSize(width: max(value.width, next.width), height: max(value.height, next.height))
  }
}

private struct StarSizeKey: SizeKey {}
private struct ControlSizeKey: SizeKey {}

struct RatingView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      RatingView(rating: 3.5, type: .small)
      RatingView(rating: 3.5, type: .large)
    }
  }
}
