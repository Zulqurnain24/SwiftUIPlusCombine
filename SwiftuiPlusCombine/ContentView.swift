//
//  ContentView.swift
//  SwiftuiPlusCombine
//
//  Created by Mohammad Zulqurnain on 12/02/2023.
//

import SwiftUI
import Combine


// MARK: Post Entity
struct Post: Decodable, Identifiable {
    let id: Int
    let title: String
    let body: String
}

// MARK: DetailView
struct DetailView: View {
    var post: Post
    
    var body: some View {
        Text(post.title)
            .font(.largeTitle)
            .padding()
            .navigationBarTitle(post.title)
    }
}

// MARK: MainView containing list view
struct ContentView: View {
    @ObservedObject var networkManager = NetworkManager()

    var body: some View {
        VStack {
            NavigationView {
                 List(networkManager.posts) { post in
                     NavigationLink(destination: DetailView(post: post)) {
                         Text(post.title)
                         Text(post.body)
                     }
                 }
             }
        }
        .onAppear(perform: networkManager.loadData)
        .onDisappear {
            networkManager.handleCancellable()
        }
    }
}

// MARK: NetworkHelper class
class NetworkManager: ObservableObject {
    @Published var error: Error?
    @Published var loading = false
    @Published var posts: [Post] = []
    
    private var cancellable: AnyCancellable?

    func loadData() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }

        self.loading = true
        self.cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Post].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.posts, on: self)
    }
    
    func handleCancellable() {
        cancellable = nil
    }

}

