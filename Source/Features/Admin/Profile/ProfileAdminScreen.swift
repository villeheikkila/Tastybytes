import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct ProfilesAdminScreen: View {
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var state: ScreenState = .loading
    @State private var profiles = [Profile]()
    @State private var searchTerm = ""

    private var filteredProfiles: [Profile] {
        guard !searchTerm.isEmpty else { return profiles }
        return profiles.filter { profile in
            profile.preferredName.localizedCaseInsensitiveContains(searchTerm)
        }
    }

    var body: some View {
        List(profiles) { profile in
            RouterLink(open: .screen(.profile(profile))) {
                ProfileEntityView(profile: profile)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm)
        .animation(.default, value: profiles)
        .navigationTitle("admin.profiles.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await load()
        }
    }

    private func load() async {
        do {
            let profiles = try await repository.profile.getAll()
            withAnimation {
                self.profiles = profiles
                state = .populated
            }
        } catch {
            withAnimation {
                state = .getState(errors: [error], withHaptics: false, feedbackEnvironmentModel: feedbackEnvironmentModel)
            }
        }
    }
}
