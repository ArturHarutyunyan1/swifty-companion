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
            ScrollView {
                VStack {
                    HStack {
                        Text("Swifty Companion")
                            .font(.headline)
                            .font(.system(size: 28))
                        Spacer()
                        Button(action: {
                            OAuth.logout()
                        }, label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        })
                        .foregroundStyle(.red)
                    }
                    .frame(height: 50)

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
                    .frame(height: 50)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    NavigationLink(destination: SearchResult(username: $username), isActive: $isActive) {
                        EmptyView()
                    }
                }
                .padding()
            }
        }
        .onAppear() {
            OAuth.checkExpiration()
        }
        .onChange(of: isActive) {
            OAuth.checkExpiration()
        }
    }
}

#Preview {
    Home()
}
