//
//  SignInEmailView.swift
//  prep
//
//  Created by Taegeon Lee on 3/7/24.
//

import SwiftUI

//MainActor is for swift concurrency (I need to check the concept) 
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
        print("success")
        print(returnedUserData)
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


struct SignInEmailView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    
    
    var body: some View {
        VStack {
            TextField("Email...", text : $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            SecureField("Password...", text : $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                        return
                    } catch {
                        
                    }
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    } catch {
                        
                    }
                }
            } label : {
                Text("Sign in")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign in With Email")
    }
}

#Preview {
    NavigationStack {
        SignInEmailView(showSignInView: .constant(false))
    }
}
