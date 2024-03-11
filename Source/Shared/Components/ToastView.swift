import EnvironmentModels
import SwiftUI

@MainActor
public struct Toast: View {
    let type: ToastEvent.ToastType
    let title: LocalizedStringKey?
    let subTitle: LocalizedStringKey?

    public init(type: ToastEvent) {
        self.type = type.type
        title = type.title
        subTitle = type.subTitle
    }

    public var body: some View {
        VStack {
            switch type {
            case let .complete(color):
                Spacer()
                AnimatedCheckmark(color: color)
                Spacer()
            case let .error(color):
                Spacer()
                AnimatedXmark(color: color)
                Spacer()
            case let .systemImage(name, color):
                Spacer()
                Image(systemName: name)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .accessibilityHidden(true)
                    .foregroundColor(color)
                    .padding(.bottom)
                Spacer()
            case let .image(name, color):
                Spacer()
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .accessibilityHidden(true)
                    .foregroundColor(color)
                    .padding(.bottom)
                Spacer()
            }

            VStack(spacing: 2) {
                if let title {
                    Text(title)
                        .font(.body.bold())
                        .multilineTextAlignment(.center)
                }
                if let subTitle {
                    Text(subTitle)
                        .font(.footnote)
                        .opacity(0.7)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .padding()
        .frame(maxWidth: 175, maxHeight: 175, alignment: .center)
        .background(.thinMaterial)
        .cornerRadius(10)
    }
}

@MainActor
private struct AnimatedXmark: View {
    @State private var percentage: CGFloat = .zero
    let color: Color
    let size: Int

    init(color: Color = .black, size: Int = 50) {
        self.color = color
        self.size = size
    }

    private var height: CGFloat {
        CGFloat(size)
    }

    private var width: CGFloat {
        CGFloat(size)
    }

    private var rect: CGRect {
        CGRect(x: 0, y: 0, width: size, height: size)
    }

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxY, y: rect.maxY))
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
        .trim(from: 0, to: percentage)
        .stroke(color, style: StrokeStyle(lineWidth: CGFloat(size / 8), lineCap: .round, lineJoin: .round))
        .animation(.spring.speed(0.75).delay(0.25), value: percentage)
        .onAppear {
            percentage = 1.0
        }
        .frame(width: width, height: height, alignment: .center)
    }
}

@MainActor
private struct AnimatedCheckmark: View {
    @State private var percentage: CGFloat = .zero
    let color: Color
    let size: Int

    init(color: Color = .black, size: Int = 50) {
        self.color = color
        self.size = size
    }

    private var height: CGFloat {
        CGFloat(size)
    }

    private var width: CGFloat {
        CGFloat(size)
    }

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: height / 2))
            path.addLine(to: CGPoint(x: width / 2.5, y: height))
            path.addLine(to: CGPoint(x: width, y: 0))
        }
        .trim(from: 0, to: percentage)
        .stroke(color, style: .init(lineWidth: CGFloat(size / 8), lineCap: .round, lineJoin: .round))
        .animation(.spring.speed(0.75).delay(0.25), value: percentage)
        .onAppear {
            percentage = 1.0
        }
        .frame(width: width, height: height, alignment: .center)
    }
}

extension Image {
    func hudModifier() -> some View {
        renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 23, maxHeight: 23, alignment: .center)
    }
}
