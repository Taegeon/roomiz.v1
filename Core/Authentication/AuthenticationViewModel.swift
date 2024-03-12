//
//  AuthenticationViewModel.swift
//  roomiz
//
//  Created by Taegeon Lee on 3/9/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

@MainActor
final class AuthenticationViewModel: ObservableObject {
  
    
    func signInGoogle() async throws
    {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting:topVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken = gidSignInResult.user.accessToken.tokenString
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        
        //try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    
    }
}
