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
            let query = API.supabase.database.from("companies").select(columns: "*")
            
            if let result =  try? await query.execute() {
                let companies = try? result.decoded(to: [Company].self)
                DispatchQueue.main.async {
                    self.companies = companies ?? []
                }
            } else {
                print("Couldn't fetch companies")
                return
            }
        }
        
        func createCompany(name: String) {
            Task {
                let addedCompany = try? await API.supabase.database.from("companies")
                    .insert(values: NewCompany(name: name), returning: .representation)
                    .execute()
                    .decoded(to: [Company].self)[0]
                
                if let company = addedCompany {
                    DispatchQueue.main.async {
                        self.companies.append(company)
                    }
                }
                
            }
        }
        
    }
    
}
