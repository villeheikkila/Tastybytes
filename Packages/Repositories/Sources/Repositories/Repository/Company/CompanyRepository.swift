import Foundation
import Models

public protocol CompanyRepository: Sendable {
    func getById(id: Int) async -> Result<Company, Error>
    func getJoinedById(id: Int) async -> Result<Company.Joined, Error>
    func getManagementDataById(id: Int) async -> Result<Company.Management, Error>
    func getUnverified() async -> Result<[Company], Error>
    func insert(newCompany: Company.NewRequest) async -> Result<Company, Error>
    func update(updateRequest: Company.UpdateRequest) async -> Result<Company.Management, Error>
    func editSuggestion(updateRequest: Company.EditSuggestionRequest) async -> Result<Void, Error>
    func delete(id: Int) async -> Result<Void, Error>
    func verification(id: Int, isVerified: Bool) async -> Result<Void, Error>
    func search(searchTerm: String) async -> Result<[Company], Error>
    func getSummaryById(id: Int) async -> Result<Summary, Error>
    func uploadLogo(companyId: Int, data: Data) async -> Result<ImageEntity, Error>
}
