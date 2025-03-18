//
//  SearchResult.swift
//  swifty-companion
//
//  Created by Artur Harutyunyan on 18.03.25.
//

import SwiftUI

struct SearchResult: View {
    @ObservedObject var OAuth = OAuthManager.shared
    @StateObject var API = ApiManager()
    @Binding var username: String
    var body: some View {
        GeometryReader {geometry in
            ScrollView {
                if let user = API.userInfo {
                    HStack {
                        Spacer()
                        AsyncImage(url: URL(string: user.cursus_users?[0].user?.image?.link ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 150, height: 150)
                        .cornerRadius(100)
                        VStack {
                            Spacer()
                            HStack {
                                Text("Login")
                                Spacer()
                                if let login = user.cursus_users?[0].user?.login {
                                    Text("\(login)")
                                }
                            }
                            HStack {
                                Text("Wallet")
                                Spacer()
                                if let wallet = user.cursus_users?[0].user?.wallet {
                                    Text("\(wallet)₳")
                                }
                            }
                            HStack {
                                Text("Location")
                                Spacer()
                                if let location = user.cursus_users?[0].user?.location {
                                    Text("\(location)")
                                        .foregroundStyle(.green)
                                } else {
                                    Text("Unavailable")
                                        .foregroundStyle(.red)
                                }
                            }
                            HStack {
                                Text("Evaluation points")
                                Spacer()
                                if let points = user.cursus_users?[0].user?.correction_point {
                                    Text("\(points)")
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                API.searchUser(username: username)
            }
        }
    }
}
