import GoTrue
import PhotosUI
import SwiftUI

struct DeleteAccountScreenView: View {
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject var currentProfile: CurrentProfile
    @EnvironmentObject var toastManager: ToastManager
    
    var body: some View {
        Form {
            Section {
                Button("Export", action: {
                    viewModel.exportData(onError: {
                        message in toastManager.toggle(.error(message))
                    })
                })
                Button("Delete Account", role: .destructive, action: {
                    viewModel.showDeleteConfirmation = true
                })
                .confirmationDialog(
                    "Are you sure you want to permanently delete your account? All data will be lost.",
                    isPresented: $viewModel.showDeleteConfirmation
                ) {
                    Button("Delete Account", role: .destructive, action: {
                        viewModel.deleteCurrentAccount(onError: {
                            message in toastManager.toggle(.error(message))
                        })
                    })
                }
            }
        }
        .navigationTitle("Delete Account")
        .fileExporter(isPresented: $viewModel.showingExporter,
                      document: viewModel.csvExport,
                      contentType: UTType.commaSeparatedText,
                      defaultFilename: "tasty_export.csv") { result in
            switch result {
            case .success:
                toastManager.toggle(.success("Data was exported as CSV"))
            case .failure:
                toastManager.toggle(.error("Error occurred while trying to export data"))
            }
        }
    }
}

extension DeleteAccountScreenView {
    enum Toast {
        case exported
        case exportError
    }
    
    @MainActor class ViewModel: ObservableObject {
        @Published var csvExport: CSVFile?
        @Published var showingExporter = false
        @Published var showDeleteConfirmation = false

        func exportData(onError: @escaping (_ error: String) -> Void) {
            Task {
                switch await repository.profile.currentUserExport() {
                case let .success(csvText):
                    await MainActor.run {
                        self.csvExport = CSVFile(initialText: csvText)
                        self.showingExporter = true
                    }
                case let .failure(error):
                    onError(error.localizedDescription)
                }
            }
        }
        
        func deleteCurrentAccount(onError: @escaping (_ error: String) -> Void) {
            Task {
                switch await repository.profile.deleteCurrentAccount() {
                case .success():
                    _ = await repository.profile.deleteCurrentAccount()
                    _ = await repository.auth.logOut()
                case let .failure(error):
                    onError(error.localizedDescription)
                }
            }
        }
    }
}
