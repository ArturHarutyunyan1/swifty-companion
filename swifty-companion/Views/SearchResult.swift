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
    @State private var cursusList: [String] = []
    @State private var selectedCursus: String = ""
    @State private var isVisible = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                Button(action: {
                    OAuth.logout()
                }, label: {
                    Text("LOgout")
                })
                if let user = API.userInfo {
                    BasicInfo(user: user)
                    DropdownMenu(geometry: geometry)
                    CursusLevel(user: user, geometry: geometry)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            Task {
                await API.searchUser(username: username)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    UpdateCursusNames()
                }
            }
        }
    }
    
    // Basic user info login, points, location and wallet
    private func BasicInfo(user: UserInfo) -> some View {
        return HStack {
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
//    Dropdown menu
    private func DropdownMenu(geometry: GeometryProxy) -> some View {
        return VStack {
            Spacer()
            HStack {
                if !cursusList.isEmpty {
                    VStack {
                        Button(action: {
                            withAnimation {
                                isVisible.toggle()
                            }
                        }, label: {
                            HStack {
                                Text("\(selectedCursus)")
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                        })
                        .padding()
                        .frame(width: geometry.size.width * 0.9, height: 50)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        if isVisible {
                            VStack {
                                ForEach(cursusList, id: \.self) {result in
                                    Button(action: {
                                        selectedCursus = result
                                    }, label: {
                                        HStack {
                                            Text("\(result)")
                                            Spacer()
                                        }
                                    })
                                    .padding()
                                }
                            }
                            .padding()
                            .transition(.opacity)
                            .animation(.easeIn(duration: 0.1), value: isVisible)
                            .frame(width: geometry.size.width * 0.9)
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                        }
                    }
                    .onAppear {
                        if let name = cursusList.first {
                            selectedCursus = name
                        }
                    }
                }
            }
        }
    }
    
//    Level
    private func CursusLevel(user: UserInfo, geometry: GeometryProxy) -> some View {
        return HStack {
            if let level = user.cursus_users {
                HStack {
                    ForEach(level.filter {$0.cursus?.name == selectedCursus}, id: \.cursus_id) {result in
                        if let levelValue = result.level {
                            let progress = levelValue.truncatingRemainder(dividingBy: 1)
                            let adjustedWidth = max(geometry.size.width * CGFloat(progress), 10)
                            VStack {
                                HStack {
                                    Spacer()
                                    Text("\(levelValue, specifier: "%.2f")")
                                    Spacer()
                                }
                            }
                            .frame(width: adjustedWidth, height: 50)
                            .background(.blue)
                            .foregroundStyle(.white)
                        }
                    }
                    Spacer()
                }
                .frame(width: geometry.size.width * 0.9, height: 50)
                .background(Color(.systemGray6))
                .cornerRadius(15)
            }
        }
    }
    
    // Helpers
    private func UpdateCursusNames() {
        if let cursusUsers = API.userInfo?.cursus_users {
            cursusList = cursusUsers.compactMap { $0.cursus?.name }
        }
        print(cursusList)
    }
}
