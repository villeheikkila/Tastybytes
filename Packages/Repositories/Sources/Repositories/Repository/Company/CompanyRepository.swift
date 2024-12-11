import Foundation
import Models

public protocol CompanyRepository: Sendable {
    func getById(id: Company.Id) async throws -> Company.Saved
    func getAll() async throws -> [Company.Saved]
    func getJoinedById(id: Company.Id) async throws -> Company.Joined
    func getDetailed(id: Company.Id) async throws -> Company.Detailed
    func getUnverified() async throws -> [Company.Saved]
    func insert(newCompany: Company.NewRequest) async throws -> Company.Saved
    func update(updateRequest: Company.UpdateRequest) async throws -> Company.Detailed
    func editSuggestion(updateRequest: Company.EditSuggestionRequest) async throws
    func deleteEditSuggestion(editSuggestion: Company.EditSuggestion) async throws
    func resolveEditSuggestion(editSuggestion: Company.EditSuggestion) async throws
    func delete(id: Company.Id) async throws
    func verification(id: Company.Id, isVerified: Bool) async throws
    func search(filterCompanies: [Company.Saved], searchTerm: String) async throws -> [Company.Saved]
    func getSummaryById(id: Company.Id) async throws -> Summary
    func makeCompanySubsidiaryOf(id: Company.Id, subsidiaryOfId: Company.Id) async throws
    func getEditSuggestions() async throws -> [Company.EditSuggestion]
    func mergeCompanies(id: Company.Id, mergeToId: Company.Id) async throws
    func removeLogo(id: Company.Id, logoId: Logo.Id) async throws
    func addLogo(id: Company.Id, logoId: Logo.Id) async throws
}
