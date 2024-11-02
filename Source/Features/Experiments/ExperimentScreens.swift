import SwiftUI

struct ExperimentScreens: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: SnackExperiment()) {
                    Text("Snacks")
                }
            }
            .navigationTitle("Experiments")
        }
    }
}

struct SnackExperiment: View {
    @Environment(SnackController.self) private var snackController
    var body: some View {
        List {
            Button("Error") {
                snackController.open(.init(mode: .snack(tint: .red, systemName: "heart", message: "Test error message"), timeout: 3))
            }
            .tint(.red)
        }
    }
}
