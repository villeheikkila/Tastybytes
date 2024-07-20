import Foundation
import Models

public protocol CompanyRepository: Sendable {
    func getById(id: Company.Id) async throws -> Company
    func getJoinedById(id: Company.Id) async throws -> Company.Joined
    func getDetailed(id: Company.Id) async throws -> Company.Detailed
    func getUnverified() async throws -> [Company]
    func insert(newCompany: Company.NewRequest) async throws -> Company
    func update(updateRequest: Company.UpdateRequest) async throws -> Company.Detailed
    func editSuggestion(updateRequest: Company.EditSuggestionRequest) async throws
    func deleteEditSuggestion(editSuggestion: Company.EditSuggestion) async throws
    func resolveEditSuggestion(editSuggestion: Company.EditSuggestion) async throws
    func delete(id: Company.Id) async throws
    func verification(id: Company.Id, isVerified: Bool) async throws
    func search(filterCompanies: [Company], searchTerm: String) async throws -> [Company]
    func getSummaryById(id: Company.Id) async throws -> Summary
    func uploadLogo(companyId: Company.Id, data: Data) async throws -> ImageEntity
    func makeCompanySubsidiaryOf(company: any CompanyProtocol, subsidiaryOf: any CompanyProtocol) async throws
}
