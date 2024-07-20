import Foundation
import Models

public protocol CompanyRepository: Sendable {
    func getById(id: Int) async throws -> Company
    func getJoinedById(id: Int) async throws -> Company.Joined
    func getDetailed(id: Int) async throws -> Company.Detailed
    func getUnverified() async throws -> [Company]
    func insert(newCompany: Company.NewRequest) async throws -> Company
    func update(updateRequest: Company.UpdateRequest) async throws -> Company.Detailed
    func editSuggestion(updateRequest: Company.EditSuggestionRequest) async throws
    func deleteEditSuggestion(editSuggestion: Company.EditSuggestion) async throws
    func resolveEditSuggestion(editSuggestion: Company.EditSuggestion) async throws
    func delete(id: Int) async throws
    func verification(id: Int, isVerified: Bool) async throws
    func search(searchTerm: String) async throws -> [Company]
    func getSummaryById(id: Int) async throws -> Summary
    func uploadLogo(companyId: Int, data: Data) async throws -> ImageEntity
    func makeCompanySubsidiaryOf(company: any CompanyProtocol, subsidiaryOf: any CompanyProtocol) async throws
}
