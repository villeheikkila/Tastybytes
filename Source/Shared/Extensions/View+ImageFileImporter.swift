import SwiftUI
import UniformTypeIdentifiers

struct ImageFileImporterViewModifier: ViewModifier {
    private let logger = Logger(label: "ImageFileImporterViewModifier")
    @Environment(SnackController.self) private var snackController
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    let allowedContentTypes: [UTType]
    
    func body(content: Content) -> some View {
        content
            .fileImporter(isPresented: $isPresented, allowedContentTypes: allowedContentTypes) { result in
                switch result {
                case let .success(url):
                    Task {
                        do {
                            guard url.startAccessingSecurityScopedResource() else {
                                snackController.open(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to create image")))
                                logger.error("Failed to access the security-scoped resource")
                                return
                            }
                            defer {
                                url.stopAccessingSecurityScopedResource()
                            }
                            let data = try Data(contentsOf: url)
                            guard let image = UIImage(data: data) else {
                                snackController.open(.init(mode: .snack(tint: .red, systemName:"exclamationmark.triangle.fill", message: "Failed to create image")))
                                logger.error("Failed to create UIImage from data")
                                return
                            }
                            selectedImage = image
                        } catch {
                            snackController.open(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to read file")))
                            logger.error("Failed to read file: \(error.localizedDescription)")
                        }
                    }
                case let .failure(error):
                    snackController.open(.init(mode: .snack(tint: .red, systemName: "", message: "Failed to import file")))
                    logger.error("File import failed: \(error.localizedDescription)")
                }
            }
    }
}

extension View {
    func imageFileImporter(
        isPresented: Binding<Bool>,
        selectedImage: Binding<UIImage?>,
        allowedContentTypeS: [UTType] = [.png]
    ) -> some View {
        modifier(ImageFileImporterViewModifier(
            isPresented: isPresented,
            selectedImage: selectedImage,
            allowedContentTypes: allowedContentTypeS
        ))
    }
}