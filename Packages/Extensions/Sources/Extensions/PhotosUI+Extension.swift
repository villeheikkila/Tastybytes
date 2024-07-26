import PhotosUI
import SwiftUI

// TODO: Get rid of this asap
extension PhotosPickerItem: @retroactive @unchecked Sendable {}

public extension PhotosPickerItem {
    func getImageData() async -> sending Data? {
        do {
            guard let imageData = try await loadTransferable(type: Data.self) else { return nil }
            return imageData
        } catch {
            return nil
        }
    }

    func getJPEG() async -> sending Data? {
        guard let imageData = await getImageData() else { return nil }
        guard let image = UIImage(data: imageData) else { return nil }
        return image.jpegData(compressionQuality: 0.5)
    }
}

public extension PhotosPickerItem {
    var imageMetadata: ImageMetadata {
        guard let assetId = itemIdentifier else { return .init() }
        let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
        guard let firstObject = assetResults.firstObject else { return .init() }
        return .init(location: firstObject.location?.coordinate, date: firstObject.creationDate)
    }
}

public struct ImageMetadata: Sendable {
    public let location: CLLocationCoordinate2D?
    public let date: Date?

    public init(location: CLLocationCoordinate2D?, date: Date?) {
        self.location = location
        self.date = date
    }

    public init() {
        location = nil
        date = nil
    }
}
