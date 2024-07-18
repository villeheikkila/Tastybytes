import Models
import SwiftUI

struct CreationInfoSection: View {
    let createdBy: Profile?
    let createdAt: Date?

    var body: some View {
        Section("location.admin.section.creator") {
            if let createdBy {
                RouterLink(open: .screen(.profile(createdBy))) {
                    HStack {
                        Avatar(profile: createdBy)
                        VStack(alignment: .leading) {
                            Text(createdBy.preferredName)
                            if let createdAt {
                                Text(createdAt, format:
                                    .dateTime
                                        .year()
                                        .month(.wide)
                                        .day())
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
            } else if let createdAt {
                Text(createdAt, format:
                    .dateTime
                        .year()
                        .month(.wide)
                        .day())
                    .foregroundColor(.secondary)
            }
        }
        .customListRowBackground()
    }
}

struct ModificationInfoView: View {
    let modificationInfo: ModificationInfo

    var body: some View {
        Section("admin.section.createdBy") {
            if let createdBy = modificationInfo.createdBy {
                RouterLink(open: .screen(.profile(createdBy))) {
                    HStack {
                        Avatar(profile: createdBy)
                        VStack(alignment: .leading) {
                            Text(createdBy.preferredName)
                            Text(modificationInfo.createdAt, format:
                                .dateTime
                                    .year()
                                    .month(.wide)
                                    .day())
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
            } else {
                Text(modificationInfo.createdAt, format:
                    .dateTime
                        .year()
                        .month(.wide)
                        .day())
                    .foregroundColor(.secondary)
            }
        }
        .customListRowBackground()

        if let updatedAt = modificationInfo.updatedAt {
            Section("admin.section.updatedBy") {
                if let updatedBy = modificationInfo.updatedBy {
                    RouterLink(open: .screen(.profile(updatedBy))) {
                        HStack {
                            Avatar(profile: updatedBy)
                            VStack(alignment: .leading) {
                                Text(updatedBy.preferredName)
                                Text(updatedAt, format:
                                    .dateTime
                                        .year()
                                        .month(.wide)
                                        .day())
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                } else {
                    Text(updatedAt, format:
                        .dateTime
                            .year()
                            .month(.wide)
                            .day())
                        .foregroundColor(.secondary)
                }
            }
            .customListRowBackground()
        }
    }
}
