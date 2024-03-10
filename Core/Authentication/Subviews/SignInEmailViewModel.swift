//
//  SignInEmailViewModel.swift
//  roomiz
//
//  Created by Taegeon Lee on 3/9/24.
//

import Foundation

@MainActor
final class SignInEmailViewModel : ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws{
        //validation purpose
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found")
            return
        }
        let returnedUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)
        try await UserManager.shared.createNewUser(auth: returnedUserData)
     
    }
    
    func signIn() async throws{
        //validation purpose
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found")
            return
        }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
       
    }

}
