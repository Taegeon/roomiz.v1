//
//  RootView.swift
//  prep
//
//  Created by Taegeon Lee on 3/7/24.
//

import SwiftUI

struct RootView: View {
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                ContentView()
                //SettingsView(showSignInView: $showSignInView)
                //ProfileView(showSignInView: $showSignInView)
                //profileview for uuid
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView, content: {
                NavigationStack{
                    AuthenticationView(showSignInView: $showSignInView)
                }
        })

    }
}

#Preview {
    RootView()
}
