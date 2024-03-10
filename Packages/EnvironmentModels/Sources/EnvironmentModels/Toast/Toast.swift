import SwiftUI

public extension Toast {
    enum BannerAnimation {
        case slide, pop
    }

    enum DisplayMode: Equatable {
        case alert
        case hud
        case banner(_ transition: BannerAnimation)
    }

    enum AlertType: Equatable {
        case complete(_ color: Color)
        case error(_ color: Color)
        case systemImage(_ name: String, _ color: Color)
        case image(_ name: String, _ color: Color)
    }
}

@MainActor
public struct Toast: View {
    let displayMode: DisplayMode
    let type: AlertType
    let title: LocalizedStringKey?
    let subTitle: LocalizedStringKey?
    let onTap: (() -> Void)?

    public init(displayMode: DisplayMode = .alert,
                type: AlertType,
                title: LocalizedStringKey? = nil,
                subTitle: LocalizedStringKey? = nil,
                onTap: (() -> Void)? = nil)
    {
        self.displayMode = displayMode
        self.type = type
        self.title = title
        self.subTitle = subTitle
        self.onTap = onTap
    }

    public var body: some View {
        switch displayMode {
        case .alert:
            alert
        case .hud:
            hud
        case .banner:
            banner
        }
    }

    public var banner: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    switch type {
                    case let .complete(color):
                        Image(systemName: "checkmark")
                            .foregroundColor(color)
                            .accessibilityHidden(true)
                    case let .error(color):
                        Image(systemName: "xmark")
                            .foregroundColor(color)
                            .accessibilityHidden(true)
                    case let .systemImage(name, color):
                        Image(systemName: name)
                            .foregroundColor(color)
                            .accessibilityHidden(true)
                    case let .image(name, color):
                        Image(name)
                            .foregroundColor(color)
                            .accessibilityHidden(true)
                    }

                    if let title {
                        Text(title)
                            .font(.headline.bold())
                    }
                }

                if let subTitle {
                    Text(subTitle)
                        .font(.subheadline)
                }
            }
            .fixedSize(horizontal: true, vertical: false)
            .multilineTextAlignment(.leading)
            .padding()
            .frame(maxWidth: 400, alignment: .leading)
            .background(.thinMaterial)
            .cornerRadius(10)
            .padding([.horizontal, .bottom])
        }
    }

    public var hud: some View {
        Group {
            HStack(spacing: 16) {
                switch type {
                case let .complete(color):
                    Image(systemName: "checkmark")
                        .hudModifier()
                        .foregroundColor(color)
                        .accessibilityHidden(true)
                case let .error(color):
                    Image(systemName: "xmark")
                        .hudModifier()
                        .foregroundColor(color)
                        .accessibilityHidden(true)
                case let .systemImage(name, color):
                    Image(systemName: name)
                        .foregroundColor(color)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .frame(width: 31, height: 31, alignment: .center)
                        .background(color.opacity(0.23), in: Circle())
                        .accessibilityHidden(true)
                        .onTapGesture {
                            onTap?()
                        }
                case let .image(name, color):
                    Image(name)
                        .hudModifier()
                        .foregroundColor(color)
                        .accessibilityHidden(true)
                }

                if title != nil || subTitle != nil {
                    VStack(alignment: .center, spacing: 1) {
                        if let title {
                            Text(title)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .multilineTextAlignment(.center)
                        }
                        if let subTitle {
                            Text(subTitle)
                                .font(.system(size: 11.5, weight: .medium, design: .rounded))
                                .opacity(0.7)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.trailing, 15)
                }
            }
            .fixedSize(horizontal: true, vertical: false)
            .padding(7)
            .frame(height: 45)
            .background(.thinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.gray.opacity(0.06), lineWidth: 1))
            .shadow(color: .black.opacity(0.1), radius: 5)
            .compositingGroup()
        }
        .padding(.top)
    }

    public var alert: some View {
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
