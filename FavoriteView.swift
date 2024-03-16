//
//  FavoriteView.swift
//  roomiz
//
//  Created by Taegeon Lee on 3/16/24.
//

import Foundation

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
