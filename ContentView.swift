//
//  ContentView.swift
//  prep
//
//  Created by Taegeon Lee on 3/3/24.
//

import SwiftUI

struct ImageData: Identifiable {
    let id = UUID()
    let imageName: String
    let category: String
    let title: String
    let description: String
}


struct SearchBar: UIViewRepresentable {
    @Binding var searchText: String
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var searchText: String

        init(searchText: Binding<String>) {
            _searchText = searchText
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.searchText = searchText
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(searchText: $searchText)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = searchText
    }
}


struct ContentView: View {
    @State private var searchText = ""
    @State private var favorites : Set<String> = []
    @State private var likesCount: [String:Int] = [:]
    @State private var likedImages : Set<String> = []
    
    let imageDataArray: [ImageData] = [
            ImageData(imageName: "room1", category: "Category A", title: "TITLE 1", description: "cozy room NYC"),
            ImageData(imageName: "room2", category: "Category B", title: "TITLE 2", description: "check my desk"),
            ImageData(imageName: "room3", category: "Category A", title: "TITLE 3", description: "flowers are my life"),
            ImageData(imageName: "room4", category: "Category C", title: "TITLE 4", description: "washroom modeling ideas"),
            ImageData(imageName: "room5", category: "Category B", title: "TITLE 5", description: "acoustic mood")
        ]
    
    var filteredImageData: [ImageData] {
        if searchText.isEmpty {
            return imageDataArray
        } else {
            return imageDataArray.filter { imageData in
                imageData.category.localizedCaseInsensitiveContains(searchText) ||
                imageData.title.localizedCaseInsensitiveContains(searchText) ||
                imageData.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        TabView {
            NavigationView {
                VStack {
                    SearchBar(searchText: $searchText)
                                       .padding()
                    ScrollView {
                       LazyVGrid(columns: Array(repeating: GridItem(), count: 1), spacing: 100) {
                           ForEach(filteredImageData){
                               imageData in
                               NavigationLink(destination: DetailView(imageData: imageData)) {
                                   VStack {
                                       Image(imageData.imageName)
                                           .resizable()
                                           .aspectRatio(contentMode: .fill)
                                           .frame(width: 300, height: 200)
                                           .cornerRadius(20)
                                           .clipped()
                                       Text(imageData.title)
                                           .font(.headline)
                                       Text(imageData.description)
                                           .font(.subheadline)
                                       HStack{
                                           Button(action: {
                                               toggleLike(imageData.title) // Toggle like
                                           }) {
                                               HStack {
                                                   Image(systemName:
                                                            likedImages.contains(imageData.title) ? "hand.thumbsup.fill" : "hand.thumbsup")
                                                   .foregroundColor(Color.red)
                                                   
      
                                                   Text("\(likesCount[imageData.title] ?? 0)") // Show likes count
                                               }
                                           }
                                           
                                           Button(action: {
                                               toggleFavorite(imageData.title)
                                           }) {
                                               Image(systemName: favorites.contains(imageData.title) ? "heart.fill" : "heart")
                                                   .foregroundColor(Color.red)
                                           }
                                       }
                                       
                                   }
                               }
                           }
                       }
                       .padding()
                   }
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            // Add action for trailing toolbar item
                        }) {
                            Image(systemName: "bell")
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                VStack {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            }
            
            ShopView().tabItem {
                VStack {
                    Image(systemName: "cart.fill")
                    Text("Shop")
                }
            }
            
            FavoriteView(favorites: favorites, imageDataArray: imageDataArray).tabItem {
                VStack {
                    Image(systemName: "heart.text.square.fill")
                    Text("Favorite")
                }
            }
            
            SecondView().tabItem {
                VStack {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
            }
        }
    }
    func toggleLike(_ category: String) {
        if likedImages.contains(category){
            likedImages.remove(category)
        }else {
            likedImages.insert(category)
        }
        
        likesCount[category, default: 0] += likedImages.contains(category) ? 1 : -1
        //likesCount[category, default: 0] += 1 - 2 * (favorites.contains(category) ? 1 : 0)
    }

    // parameter category should be title
    func toggleFavorite(_ category: String) {
            if favorites.contains(category) {
                favorites.remove(category)
            } else {
                favorites.insert(category)
            }
        }
}





struct DetailView: View {
    let imageData: ImageData
    
    var body: some View {
        
        VStack {
            Image(imageData.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            Text(imageData.title)
                .font(.title)
                .padding()
            Text(imageData.description)
                .font(.body)
                .padding()
            Spacer()
        }
        
        .navigationTitle("Detail")
    }
}


struct FirstView: View {
    var body: some View {
        Text("Holy shit")
    }
}

struct ShopView: View {
    var body: some View {
            Text("shop")
        
    }
    
}
struct FavoriteView: View {
    let favorites: Set<String> // Pass the set of favorites
    let imageDataArray: [ImageData]

    init(favorites: Set<String>, imageDataArray: [ImageData]) {
        self.favorites = favorites
        self.imageDataArray = imageDataArray
    }

    var body: some View {
        
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 1), spacing: 100) {
                    ForEach(imageDataArray.filter { favorites.contains($0.title) }) { imageData in
                        NavigationLink(destination: DetailView(imageData: imageData)) {
                            VStack {
                                Image(imageData.imageName) // Display image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 300, height: 200)
                                    .cornerRadius(20)
                                    .clipped()
                                Text(imageData.title) // Display title
                                    .font(.headline)
                                // You can display additional information related to the favorite item here
                            }
                        }
                    }
                }
                .padding()
            }
        }
        

        
    }
}

struct SecondView: View { //settingsview
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                ProfileView(showSignInView: $showSignInView)
                SettingsView(showSignInView: $showSignInView)
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
    ContentView()
}
