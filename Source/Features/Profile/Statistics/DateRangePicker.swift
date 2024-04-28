import Models
import SwiftUI

struct DateRangePicker: View {
    @State private var page = 0
    @Binding var timePeriod: StatisticsTimePeriod
    @Binding var dateRange: ClosedRange<Date>

    var body: some View {
        Picker("checkIn.statistics.timePeriod.segment.picker", selection: $timePeriod) {
            ForEach(StatisticsTimePeriod.allCases, id: \.self) { segment in
                Text(segment.label)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, -8)
        HStack {
            PageButton(direction: .decrement, page: $page)
            Spacer()
            Text(dateRange.title)
            Spacer()
            PageButton(direction: .increment, page: $page)
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
