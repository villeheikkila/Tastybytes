import Components
import Logging
import Models
import Repositories
import SwiftUI
import UniformTypeIdentifiers

struct LogoAdminScreen: View {
    typealias OnSelectionCallback = (Logo.Saved) -> Void
    private let logger = Logger(label: "LogoScreen")
    @Environment(AdminModel.self) private var adminModel
    @Environment(\.dismiss) private var dismiss
    @State private var showFileImporter = false
    @State private var selectedLogo: UIImage?
    @State private var label: String = ""
    @FocusState private var isFocused: Bool
    
    let onSelection: OnSelectionCallback?
    
    init(onSelection: OnSelectionCallback? = nil) {
        self.onSelection = onSelection
    }
    
    func selectLogo(_ logo: Logo.Saved) {
        onSelection?(logo)
        dismiss()
    }

    var body: some View {
        List(adminModel.logos) { logo in
            LogoAdminRow(logo: logo, onDelete: { logo in
                await adminModel.deleteLogo(logo)
            }, onRename: { logo, label in await adminModel.updateLogo(logo: logo, label: label) })
            .onTapGesture {
                selectLogo(logo)
            }
        }
        .animation(.interpolatingSpring, value: adminModel.logos)
        .listStyle(.insetGrouped)
        .refreshable {
            await adminModel.loadLogos()
        }
        .navigationBarTitle("admin.logos.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("admin.logos.save", systemImage: "plus") {
                    showFileImporter = true
                }
            }
        }
        .task {
            if adminModel.logos.isEmpty {
                await adminModel.loadLogos()
            }
        }
        .sheet(isPresented: $selectedLogo.isNotNull()) {
            NavigationStack {
                if let selectedLogo {
                    Form {
                        Section {
                            HStack {
                                Spacer()
                                Image(uiImage: selectedLogo)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 128)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.clear)
                        Section {
                            TextField("admin.logos.label.placeholder", text: $label)
                        }
                        AsyncButton("admin.logos.save", role: .destructive) {
                            await adminModel.createLogo(image: selectedLogo, label: label, onSuccess: {
                                self.selectedLogo = nil
                                label = ""
                            })
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.insetGrouped)
                    .scrollBounceBehavior(.basedOnSize)
                }
            }
            .presentationDetents([.height(400)])
        }
        .imageFileImporter(isPresented: $showFileImporter, selectedImage: $selectedLogo)
    }
}

struct LogoAdminRow: View {
    @State private var showDeleteConfirmationDialog = false
    @State private var showRenameAlert = false
    @State private var newLabel = ""
    let logo: Logo.Saved
    let onDelete: (Logo.Saved) async -> Void
    let onRename: (Logo.Saved, String) async -> Void

    var body: some View {
        Section {
            HStack {
                ImageEntityView(image: logo) { image in
                    image
                        .renderingMode(.original)
                        .resizable()
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
                .accessibility(hidden: true)
                Text(logo.label)
            }
            .contextMenu {
                ControlGroup {
                    Button("labels.rename", systemImage: "pencil") {
                        newLabel = logo.label
                        showRenameAlert = true
                    }
                    Button("labels.delete", systemImage: "trash") {
                        showDeleteConfirmationDialog = true
                    }
                }
            }
            .alert("labels.rename.title", isPresented: $showRenameAlert) {
                TextField("labels.rename.placeholder", text: $newLabel)
                Button("labels.cancel", role: .cancel) {}
                Button("labels.save") {
                    if !newLabel.isEmpty {
                        Task {
                            await onRename(logo, newLabel)
                        }
                    }
                }
            } message: {
                Text("admin.logo.changeLabel")
            }
            .confirmationDialog(
                "logo.admin.delete.confirmation",
                isPresented: $showDeleteConfirmationDialog,
                titleVisibility: .visible,
                presenting: logo
            ) { presenting in
                AsyncButton(
                    "logo.admin.delete.label \(presenting.label)",
                    action: {
                        await onDelete(presenting)
                    }
                )
                .tint(.green)
            }
        }
    }
}
