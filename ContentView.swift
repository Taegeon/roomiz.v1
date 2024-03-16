//
//  ContentView.swift
//  prep
//
//  Created by Taegeon Lee on 3/3/24.
//

import SwiftUI
import Firebase

struct ImageData: Identifiable {
    let id = UUID()
    let imageName: String
    let category: String
    let title: String
    let description: String
}

// in order to save it into firebase db. Making separate collections
struct ImageDataModel: Codable {
    let imageName : String
    let category : String
    let title : String
    let description : String
}
//firebase likes
struct LikesModel : Codable {
    let title : String
    let count : Int
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
        let searchBar = UISearchBar(frame: .zero )
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        
        
        
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
    @State private var showSearchBar = false
    
    private func loadInitialLikesCount() {
        FirestoreManager.shared.getLikesData { likesData in
            for like in likesData {
                likesCount[like.title] = like.count
            }
        }
    }
    
    

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
                    if showSearchBar {
                        SearchBar(searchText: $searchText)
                            .padding()
                    }
                    ZStack(alignment: .bottomTrailing) {
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
                        } // end of scrollview
                        NavigationLink(destination: AddCategoryView()) {
                            Image(systemName: "plus.app.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 40))
                                .frame(width: 70, height: 100)
                        }
                    } // end of ZStack
                }// end of VStack
                .navigationTitle("Roomiz")
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showSearchBar.toggle()
                        }) {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            // This is for the notification
                        }) {
                            Image(systemName: "bell")
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }.onAppear {
                loadInitialLikesCount()
            }

            .tabItem {
                VStack {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            }
            
            ShopView(imageDataArray: imageDataArray).tabItem {
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


    
    func toggleLike(_ title: String) {
        if likedImages.contains(title){
            likedImages.remove(title)
        }else {
            likedImages.insert(title)
        }
        
        likesCount[title, default: 0] += likedImages.contains(title) ? 1 : -1
        let likesData = LikesModel(title: title, count: likesCount[title] ?? 0)
        FirestoreManager.shared.saveLikesData(likesData: likesData)
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


struct AddCategoryView: View {
    var body: some View {
        Text("Add Category View")
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
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    let imageDataArray: [ImageData]

    var body: some View {
        NavigationView {
            VStack{
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(imageDataArray.indices, id: \.self) { index in
                            ShopImageView(imageData: imageDataArray[index])
                                .frame(width: UIScreen.main.bounds.width, height: 200) // Adjust the height as needed
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: CGFloat(currentIndex) * -UIScreen.main.bounds.width)
                    .animation(.easeInOut)
                    .onReceive(timer) { _ in
                        withAnimation {
                            currentIndex = (currentIndex + 1) % imageDataArray.count
                        }
                    }
                }
                .frame(height: 100) // Adjust the height as needed
                .padding(.top, -250)
                .navigationTitle("Shop🛒")

            }
        }
    }
}

struct ShopImageView: View {
    let imageData: ImageData
    
    var body: some View {
        VStack {
            Image(imageData.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            // Add any additional content you want to display for each image
        }
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
            }.navigationTitle("My Favorites ❤️")
        }
    
    }
}

struct SecondView: View { //settingsview
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                ProfileView(showSignInView: $showSignInView)
                //SettingsView(showSignInView: $showSignInView)
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
