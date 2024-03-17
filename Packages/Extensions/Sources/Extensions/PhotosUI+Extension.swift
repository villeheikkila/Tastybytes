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

public extension PhotosPickerItem {
    var imageMetadata: ImageMetadata {
        #if !os(watchOS)
            guard let assetId = itemIdentifier else { return .init() }
            let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
            guard let firstObject = assetResults.firstObject else { return .init() }
            return .init(location: firstObject.location?.coordinate, date: firstObject.creationDate)
        #else
            .init()
        #endif
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
