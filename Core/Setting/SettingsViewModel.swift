//
//  SettingsViewModel.swift
//  roomiz
//
//  Created by Taegeon Lee on 3/9/24.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        let email = "hello123@gmail.com"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }

    func updatePassword() async throws {
        let password = "123"
        try await AuthenticationManager.shared.updatePassword(password: password)

    }
}
