import Charts
import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInsByTimeBucketView: View {
    private let logger = Logger(category: "CheckInsByTimeBucketView")
    @Environment(Repository.self) private var repository
    @State private var isLoading = false
    @State private var checkInsPerDay = [CheckInsPerDay]()
    @State private var timePeriod: StatisticsTimePeriod = .week

    @State private var page = 0
    @State private var dateRange: ClosedRange<Date> = Date.now ... Date.now

    let profile: Profile

    var checkInsInRange: [CheckInsPerDay] {
        checkInsPerDay.filter { checkIn in
            dateRange.contains(checkIn.checkInDate)
        }
    }

    var checkInsTimeBuckets: [CheckInsTimeBucket] {
        CheckInsTimeBucket.getBuckets(checkInsPerDay: checkInsPerDay, timePeriod: timePeriod, dateRange: dateRange)
    }

    var body: some View {
        Section {
            DateRangePicker(page: $page, timePeriod: $timePeriod, dateRange: $dateRange)
            CheckInsByTimeRangeChart(profile: profile, checkInsTimeBuckets: checkInsTimeBuckets)
                .simultaneousGesture(switchTabGesture)
            TimePeriodStatisticSegmentView(checkInsPerDay: checkInsInRange)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .task {
            await loadStatisticsForTimePeriod()
        }
    }

    func loadStatisticsForTimePeriod() async {
        guard isLoading == false else { return }
        isLoading = true
        switch await repository.profile.getNumberOfCheckInsByDay(.init(profileId: profile.id)) {
        case let .success(checkInsPerDay):
            self.checkInsPerDay = checkInsPerDay
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed loading time period statistics. Error: \(error) (\(#file):\(#line))")
        }
        isLoading = false
    }

    private let switchPageGestureDistance = 50.0

    private var switchTabGesture: some Gesture {
        DragGesture(minimumDistance: switchPageGestureDistance)
            .onEnded { value in
                let translationWidth = value.translation.width
                if translationWidth < -switchPageGestureDistance {
                    page += 1
                } else if translationWidth > switchPageGestureDistance {
                    page -= 1
                }
            }
    }
}
