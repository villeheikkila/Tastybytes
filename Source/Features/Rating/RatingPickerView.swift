import SwiftUI

public struct RatingPickerView: View {
    @Binding var rating: Double
    @State private var starSize: CGSize = .zero
    @State private var controlSize: CGSize = .zero
    @GestureState private var dragging = false

    let outOf: Int

    public init(rating: Binding<Double>, outOf: Int = 5) {
        _rating = rating
        self.outOf = outOf
    }

    public var body: some View {
        ZStack {
            HStack {
                ForEach(0 ... outOf - 1, id: \.self) { i in
                    Image(systemName: "star")
                        .accessibilityHidden(true)
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
                }.accessibilityLabel("rating.outOf \(rating) \(outOf)")
            }
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(key: ControlSizeKey.self, value: proxy.size)
                }
            )
            .onPreferenceChange(StarSizeKey.self) { size in
                MainActor.assumeIsolated {
                    starSize = size
                }
            }
            .onPreferenceChange(ControlSizeKey.self) { size in
                MainActor.assumeIsolated {
                    controlSize = size
                }
            }
            Color.clear
                .frame(width: controlSize.width, height: controlSize.height)
                .contentShape(.rect)
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
        let totalPaddingWidth = controlSize.width - Double(outOf) * singleStarWidth
        let singlePaddingWidth = totalPaddingWidth / (Double(outOf) - 1)
        let starWithSpaceWidth = Double(singleStarWidth + singlePaddingWidth)
        let xAxis = Double(position.x)
        let starIdx = Int(xAxis / starWithSpaceWidth)
        let starPercent = xAxis.truncatingRemainder(dividingBy: starWithSpaceWidth) / Double(singleStarWidth)
        let rating = Double(starIdx) + round(starPercent * 4) / 4
        return min(Double(outOf), max(0, rating))
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
