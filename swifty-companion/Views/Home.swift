//
//  Home.swift
//  swifty-companion
//
//  Created by Artur Harutyunyan on 18.03.25.
//

import SwiftUI

struct Home: View {
    @ObservedObject var OAuth = OAuthManager.shared
    @State private var username: String = ""
    @State private var isActive = false
    var body: some View {
        NavigationView {
            GeometryReader {geometry in
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Username", text: $username)
                            .onSubmit {
                                isActive = true
                            }
                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .frame(width: geometry.size.width * 0.9, height: 50)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    NavigationLink(destination: SearchResult(username: $username), isActive: $isActive) {
                        EmptyView()
                    }
                    Button(action: {
                        Task {
                            OAuth.logout()
                        }
                    }, label: {
                        Text("Log out")
                    })
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

#Preview {
    Home()
}
