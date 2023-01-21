import SwiftUI

struct RatingView: View {
  let rating: Double
  let type: StarType
  @State private var starSize: CGSize = .zero
  @State private var controlSize: CGSize = .zero
  @GestureState private var dragging: Bool = false

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
      .background(
        GeometryReader { proxy in
          Color.clear.preference(key: ControlSizeKey.self, value: proxy.size)
        }
      )
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
        GeometryReader { proxy in
          Color.clear.preference(key: StarSizeKey.self, value: proxy.size)
        }
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
