import Components

import Extensions
import Logging
import Models
import Repositories
import SwiftUI

struct TimePeriodStatisticSegmentView: View {
    let checkInsPerDay: [Profile.CheckInsPerDay]

    private var totalCheckInsPerPeriod: (totalCheckIns: Int, totalUniqueChecKins: Int) {
        checkInsPerDay.reduce((totalCheckIns: 0, totalUniqueChecKins: 0)) { value, day in
            (totalCheckIns: value.totalCheckIns + day.numberOfCheckIns, totalUniqueChecKins: value.totalUniqueChecKins + day.uniqueProductCount)
        }
    }

    var body: some View {
        VStack {
            LabeledContent("checkIn.statistics.checkIns.label", value: totalCheckInsPerPeriod.totalCheckIns.formatted())
            LabeledContent("checkIn.statistics.newProducts.label", value: totalCheckInsPerPeriod.totalUniqueChecKins.formatted())
        }
    }
}
