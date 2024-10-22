import Charts
import Components

import Extensions
import Models
import Logging
import Repositories
import SwiftUI

struct CheckInsByTimeBucketView: View {
    private let logger = Logger(label: "CheckInsByTimeBucketView")
    @Environment(Repository.self) private var repository
    @State private var isLoading = false
    @State private var checkInsPerDay = [Profile.CheckInsPerDay]()
    @State private var timePeriod: StatisticsTimePeriod = .week

    @State private var page = 0
    @State private var dateRange: ClosedRange<Date> = Date.now ... Date.now

    let profile: Profile.Saved

    private var checkInsInRange: [Profile.CheckInsPerDay] {
        checkInsPerDay.filter { checkIn in
            dateRange.contains(checkIn.checkInDate)
        }
    }

    private var checkInsTimeBuckets: [CheckInsTimeBucket] {
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

    private func loadStatisticsForTimePeriod() async {
        guard isLoading == false else { return }
        isLoading = true
        do {
            let checkInsPerDay = try await repository.profile.getNumberOfCheckInsByDay(.init(profileId: profile.id))
            self.checkInsPerDay = checkInsPerDay
        } catch {
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
