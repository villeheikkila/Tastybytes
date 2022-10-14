//
//  ContentView.swift
//  tasted
//
//  Created by Ville Heikkilä on 5.10.2022.
//

import SwiftUI

import Supabase

struct CompanyView: View {
    @StateObject private var model = CompanyViewModel()
    @State var name = ""

    var body: some View {
        VStack {
            TextField("Company name", text: $name)
            Button("Add company") {
                model.createCompany(name: name)
            }

            ForEach(model.companies) {
                company in Text(company.name)
            }
        }.task {
            try? await model.getCompanies()
        }
    }
}

extension CompanyView {
    @MainActor class CompanyViewModel: ObservableObject {
        @Published var companies: [Company] = []

        func getCompanies() async throws {
            Task {
                let companies = try await SupabaseCompanyRepository().loadAll()
                DispatchQueue.main.async {
                    self.companies = companies
                }
            }
        }

        func createCompany(name: String) {
            let newCompany = NewCompany(name: name)
            Task {
                let company = try await SupabaseCompanyRepository().insert(newCompany: newCompany)
                DispatchQueue.main.async {
                    self.companies.append(company)
                }
            }
        }
    }
}
