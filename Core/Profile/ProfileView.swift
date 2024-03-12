//
//  ProfileView.swift
//  roomiz
//
//  Created by Taegeon Lee on 3/9/24.
//

import SwiftUI
import PhotosUI






struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State private var selectedItem : PhotosPickerItem? = nil
    @State private var url: URL? = nil
    
    
    var body: some View {
        List {
            if let user = viewModel.user {
                Text("UserId: \(user.userId)")
                if let email = user.email {
                    Text("email: \(email.description)")
                }
            }
            // I will keep it for now, but it needs to be fixed
            
            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                Text("Select a photo")
            }
            if let urlString = viewModel.user?.profileImagePathUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                        .frame(width: 150, height: 150)
                }
            }
            if viewModel.user?.profileImagePath != nil {
                Button("Delete image") {
                    viewModel.deleteProfileImage()
                }
            }
            
        }
        .task{
            try? await viewModel.loadCurrentUser()
            

            
            
        }
        .onChange(of: selectedItem, perform: { newValue in
            if let newValue {
                viewModel.saveProfileImage(item: newValue)
            }
        })
        .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView(showSignInView: $showSignInView)
                    } label: {
                        Image(systemName: "gear")
                            .font(.headline)
                    }
                }
            }
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
