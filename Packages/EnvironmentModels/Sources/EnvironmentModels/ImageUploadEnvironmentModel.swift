import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
@Observable
public class ImageUploadEnvironmentModel {
    private let logger = Logger(category: "ImageUploadEnvironmentModel")

    public var uploadedImageForCheckIn: CheckIn?
    public var alertError: AlertError?

    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public func uploadCheckInImage(checkIn: CheckIn, images: [UIImage]) {
        Task(priority: .userInitiated) {
            var uploadedImages = [ImageEntity]()
            for image in images {
                let blurHash: String? = if let hash = image.resize(to: 100)?.blurHash(numberOfComponents: (5, 5)) {
                    BlurHash(hash: hash, height: image.size.height, width: image.size.width).encoded
                } else {
                    nil
                }
                guard let data = image.jpegData(compressionQuality: 0.7) else { return }
                switch await repository.checkIn.uploadImage(id: checkIn.id, data: data, userId: checkIn.profile.id, blurHash: blurHash) {
                case let .success(imageEntity):
                    uploadedImages.append(imageEntity)
                case let .failure(error):
                    guard !error.isCancelled else { return }
                    alertError = .init()
                    logger.error("Failed to upload image to check-in '\(checkIn.id)'. Error: \(error) (\(#file):\(#line))")
                }
            }
            uploadedImageForCheckIn = checkIn.copyWith(images: checkIn.images + uploadedImages)
        }
    }
}
