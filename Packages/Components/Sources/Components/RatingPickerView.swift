import SwiftUI

public struct RatingPickerView: View {
    public enum IncrementType {
        case small, large

        var divider: Double {
            switch self {
            case .large:
                2
            case .small:
                4
            }
        }
    }

    @Binding var rating: Double
    @State private var starSize: CGSize = .zero
    @State private var controlSize: CGSize = .zero
    @GestureState private var dragging = false

    let incrementType: IncrementType

    public init(
        rating: Binding<Double>,
        incrementType: IncrementType
    ) {
        _rating = rating
        self.incrementType = incrementType
    }

    public var body: some View {
        ZStack {
            HStack {
                ForEach(0 ... 4, id: \.self) { i in
                    Image(systemName: "star")
                        .overlay(
                            GeometryReader { geo in
                                let fraction = rating - Double(i)
                                let paintedPortion = min(5, max(0, fraction))
                                let width = geo.size.width * paintedPortion + (paintedPortion > 0.75 ? 5 : 0)
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .mask(
                                        Rectangle()
                                            .frame(width: width, height: geo.size.height)
                                            .offset(x: -geo.size.width / 4)
                                    )
                            }
                        )
                        .font(.title)
                        .background(
                            GeometryReader { proxy in
                                Color.clear.preference(key: StarSizeKey.self, value: proxy.size)
                            }
                        )
                        .frame(width: starSize.width, height: starSize.height)
                        .foregroundColor(.yellow)
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
