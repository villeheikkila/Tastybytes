import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct CompanyAdminSheet: View {
    private let logger = Logger(category: "EditCompanySheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var company: Company
    @State private var newCompanyName = ""
    @State private var selectedLogo: PhotosPickerItem?

    let onSuccess: () async -> Void

    init(company: Company, onSuccess: @escaping () async -> Void) {
        _company = State(initialValue: company)
        _newCompanyName = State(initialValue: company.name)
        self.onSuccess = onSuccess
    }

    var body: some View {
        Form {
            Section("company.admin.section.details") {
                LabeledTextField(title: "company.edit.name.placeholder", text: $newCompanyName)
                LabeledContent("labels.id", value: "\(company.id)")
                    .textSelection(.enabled)
                LabeledContent("verification.verified.label", value: "\(company.isVerified)".capitalized)
            }
            .customListRowBackground()

            EditLogoSection(logos: company.logos, onUpload: { imageData in
                await uploadLogo(data: imageData)
            }, onDelete: { imageEntity in
                await deleteLogo(entity: imageEntity)
            })
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("company.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task(id: selectedLogo) {
            guard let selectedLogo else { return }
            guard let data = await selectedLogo.getJPEG() else {
                logger.error("Failed to convert image to JPEG")
                return
            }
            await uploadLogo(data: data)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItem(placement: .primaryAction) {
            ProgressButton("labels.edit", action: {
                await editCompany(onSuccess: onSuccess)
            })
            .disabled(!newCompanyName.isValidLength(.normal) || newCompanyName == company.name)
        }
    }

    func editCompany(onSuccess: () async -> Void) async {
        switch await repository.company.update(updateRequest: Company.UpdateRequest(id: company.id, name: newCompanyName)) {
        case let .success(company):
            withAnimation {
                self.company = .init(company: company)
            }
            router.open(.toast(.success()))
            await onSuccess()
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to edit company. Error: \(error) (\(#file):\(#line))")
        }
    }

    func uploadLogo(data: Data) async {
        switch await repository.company.uploadLogo(companyId: company.id, data: data) {
        case let .success(imageEntity):
            company = company.copyWith(logos: company.logos + [imageEntity])
            logger.info("Succesfully uploaded company logo: \(imageEntity.file)")
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Uploading company logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteLogo(entity: ImageEntity) async {
        switch await repository.imageEntity.delete(from: .companyLogos, entity: entity) {
        case .success:
            withAnimation {
                company = company.copyWith(logos: company.logos.removing(entity))
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }
}
