import Extensions
import Logging
import Models
import Repositories
import SwiftUI

@MainActor
@Observable
public final class CheckInUploadModel {
    private let logger = Logger(label: "CheckInUploadModel")

    public var uploadedImageForCheckIn: CheckIn.Joined?
    public var alertError: AlertEvent?

    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public func uploadCheckInImage(checkIn: CheckIn.Joined, images: [UIImage]) {
        Task(priority: .userInitiated) {
            var uploadedImages = [ImageEntity.Saved]()
            for image in images {
                let blurHash: String? = if let hash = image.resize(to: 100)?.blurHash(numberOfComponents: (5, 5)) {
                    BlurHash(hash: hash, height: image.size.height, width: image.size.width).encoded
                } else {
                    nil
                }
                guard let data = image.jpegData(compressionQuality: 0.7) else { return }
                do {
                    let imageEntity = try await repository.checkIn.uploadImage(id: checkIn.id, data: data, userId: checkIn.profile.id, blurHash: blurHash)
                    uploadedImages.append(imageEntity)
                } catch {
                    guard !error.isCancelled else { return }
                    alertError = .init()
                    logger.error("Failed to upload image to check-in '\(checkIn.id)'. Error: \(error) (\(#file):\(#line))")
                }
            }
            uploadedImageForCheckIn = checkIn.copyWith(images: checkIn.images + uploadedImages)
        }
    }
}
