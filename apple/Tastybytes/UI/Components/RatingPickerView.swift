import SwiftUI

struct RatingPickerView: View {
  enum IncrementType {
    case small, large

    var divider: Double {
      switch self {
      case .large:
        return 2
      case .small:
        return 4
      }
    }
  }

  @Binding var rating: Double
  @State private var starSize: CGSize = .zero
  @State private var controlSize: CGSize = .zero
  @GestureState private var dragging = false

  let incrementType: IncrementType

  var body: some View {
    ZStack {
      HStack {
        ForEach(0 ..< Int(rating), id: \.self) { _ in
          fullStar
        }
        if rating != floor(rating) {
          halfStar
        }
        ForEach(0 ..< Int(Double(5) - rating), id: \.self) { _ in
          emptyStar
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
        .gesture(
          DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
              rating = rating(at: value.location)
            }
        )
    }
  }

  private var fullStar: some View {
    Image(systemName: "star.fill")
      .star(size: starSize)
      .foregroundColor(.yellow)
  }

  private var halfStar: some View {
    Image(systemName: "star.leadinghalf.fill")
      .star(size: starSize)
      .foregroundColor(.yellow)
  }

  private var emptyStar: some View {
    Image(systemName: "star")
      .star(size: starSize)
  }

  private func rating(at position: CGPoint) -> Double {
    let singleStarWidth = starSize.width
    let totalPaddingWidth = controlSize.width - Double(5) * singleStarWidth
    let singlePaddingWidth = totalPaddingWidth / (Double(5) - 1)
    let starWithSpaceWidth = Double(singleStarWidth + singlePaddingWidth)
    let xAxis = Double(position.x)
    let starIdx = Int(xAxis / starWithSpaceWidth)
    let starPercent = xAxis.truncatingRemainder(dividingBy: starWithSpaceWidth) / Double(singleStarWidth)
    let rating = Double(starIdx) + round(starPercent * incrementType.divider) / incrementType.divider
    return min(5, max(0, rating))
  }
}

private extension Image {
  func star(size: CGSize) -> some View {
    font(.title)
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
