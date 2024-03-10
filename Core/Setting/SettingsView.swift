//
//  SettingsView.swift
//  prep
//
//  Created by Taegeon Lee on 3/7/24.
//

import SwiftUI


                                    



struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        
                    }
                }
            }
            
            
            emailSection
            
            
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(showSignInView: .constant(false))
    }
}

extension SettingsView {
    private var emailSection: some View {
        Section {
            Button("Reset Password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("password reset!")
                    } catch {
                        
                    }
                }
            }
            Button("Update Email") {
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("email updated!")
                    } catch {
                        
                    }
                }
            }
            Button("Update Password") {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        print("password updated!")
                    } catch {
                        
                    }
                }
            }
        } header : {
            Text("Email Functions")
        }
    }
}
