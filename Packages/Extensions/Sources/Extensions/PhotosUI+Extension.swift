import PhotosUI
import SwiftUI

public extension PhotosPickerItem {
    func getJPEG() async -> Data? {
        do {
            guard let imageData = try await loadTransferable(type: Data.self) else { return nil }
            guard let image = UIImage(data: imageData) else { return nil }
            return image.jpegData(compressionQuality: 0.5)
        } catch {
            return nil
        }
    }
}
