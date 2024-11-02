import Models
import SwiftUI

struct DateRangePicker: View {
    @Environment(Router.self) private var router
    @Environment(ProfileModel.self) private var profileModel
    @Binding var page: Int
    @Binding var timePeriod: StatisticsTimePeriod
    @Binding var dateRange: ClosedRange<Date>

    var body: some View {
        ZStack {
            Picker("checkIn.statistics.timePeriod.segment.picker", selection: $timePeriod) {
                ForEach(StatisticsTimePeriod.allCases) { segment in
                    DateRangePrickerItemView(timePeriod: segment)
                        .tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, -8)

            if profileModel.isRegularMember {
                Color.clear
                    .contentShape(.rect)
                    .onTapGesture {
                        router.open(.sheet(.subscribe))
                    }
            }
        }

        HStack {
            PageButton(direction: .decrement, page: $page)
                .disabled(profileModel.isRegularMember)
            Spacer()
            Text(dateRange.title)
            Spacer()
            PageButton(direction: .increment, page: $page)
                .disabled(profileModel.isRegularMember)
        }
        .onChange(of: timePeriod) { _, newTimePeriod in
            withAnimation {
                page = 0
                if let dateRange = newTimePeriod.getTimeRange(page: page) {
                    self.dateRange = dateRange
                }
            }
        }
        .onChange(of: page, initial: true) { _, newPage in
            if let dateRange = timePeriod.getTimeRange(page: newPage) {
                withAnimation {
                    self.dateRange = dateRange
                }
            }
        }
    }
}

struct DateRangePrickerItemView: View {
    @Environment(ProfileModel.self) private var profileModel
    let timePeriod: StatisticsTimePeriod

    @State private var renderedImage: UIImage?

    private var isEnabled: Bool {
        timePeriod == .week || profileModel.isProMember
    }

    private let height: Double = 38

    var body: some View {
        Group {
            if let image = renderedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                itemContent
                    .task {
                        await renderImage()
                    }
            }
        }
        .frame(height: height)
    }

    private var itemContent: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(timePeriod.label)
                .font(.body)
            if !isEnabled {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
        }
    }

    private func renderImage() async {
        let renderer = ImageRenderer(content:
            itemContent
                .frame(height: height)
                .fixedSize(horizontal: false, vertical: true))
        renderer.scale = UIScreen.main.scale
        renderedImage = renderer.uiImage
    }
}

struct PageButton: View {
    enum Direction {
        case increment
        case decrement

        var systemImage: String {
            switch self {
            case .decrement:
                "chevron.left"
            case .increment:
                "chevron.right"
            }
        }

        var label: LocalizedStringKey {
            switch self {
            case .decrement: "timePeriod.previous"
            case .increment: "timePeriod.next"
            }
        }
    }

    @State private var isPressed = false
    let direction: Direction
    @Binding var page: Int

    public var body: some View {
        Button(direction.label, systemImage: direction.systemImage, action: {
            let newPage = page + (direction == .decrement ? -1 : 1)
            guard newPage <= 0 else { return }
            page = newPage
        })
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .symbolEffect(.bounce.down, value: isPressed)
    }
}
