//
//  SearchResult.swift
//  swifty-companion
//
//  Created by Artur Harutyunyan on 18.03.25.
//

import SwiftUI
import Charts

enum AppTab : CaseIterable, Hashable {
    case projects, achievements, skills
}

struct SearchResult: View {
    @ObservedObject var OAuth = OAuthManager.shared
    @StateObject var API = ApiManager()
    @Binding var username: String
    @State private var cursusList: [String] = []
    @State private var selectedCursus: String = ""
    @State private var isVisible = false
    @State private var cursusIndex = 0
    @State private var selectedTab: AppTab = .projects
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                HStack {
                    Spacer()
                    Button(action: {
                        OAuth.logout()
                    }, label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    })
                    .foregroundStyle(.red)
                }
                if let user = API.userInfo {
                    BasicInfo(user: user)
                    DropdownMenu(geometry: geometry)
                    CursusLevel(user: user, geometry: geometry)
                    Tab(geometry: geometry)
                    VStack {
                        switch (selectedTab) {
                        case .projects:
                            ProjectList(user: user, geometry: geometry)
                        case .achievements:
                            Achievements(user: user, geometry: geometry)
                        case .skills:
                            Skills(user: user, geometry: geometry)
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            Task {
                await API.searchUser(username: username)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    UpdateCursusNames()
                    cursusIndex = CursusToId(cursus: selectedCursus)
                }
            }
        }
        .onChange(of: selectedCursus) {
            cursusIndex = CursusToId(cursus: selectedCursus)
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
                            let adjustedWidth = max(geometry.size.width * CGFloat(progress) + 60, 10)
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
//    Tab selection
    private func Tab(geometry: GeometryProxy) -> some View {
        return VStack {
            HStack {
                Button(action: {
                    selectedTab = AppTab.projects
                }, label: {
                    HStack {
                        Image(systemName: "apple.terminal.on.rectangle")
                    }
                    .frame(width: geometry.size.width * 0.3)
                })
                .padding()
                .frame(width: geometry.size.width * 0.3)
                .background(Color(.systemGray6))
                .foregroundStyle(.black)
                .cornerRadius(15)
                Button(action: {
                    selectedTab = AppTab.achievements
                }, label: {
                    HStack {
                        Image(systemName: "trophy")
                    }
                    .frame(width: geometry.size.width * 0.3)
                })
                .padding()
                .frame(width: geometry.size.width * 0.3)
                .background(Color(.systemGray6))
                .foregroundStyle(.black)
                .cornerRadius(15)
                Button(action: {
                    selectedTab = AppTab.skills
                }, label: {
                    HStack {
                        Image(systemName: "hammer")
                    }
                    .frame(width: geometry.size.width * 0.3)
                })
                .padding()
                .frame(width: geometry.size.width * 0.3)
                .background(Color(.systemGray6))
                .foregroundStyle(.black)
                .font(.system(size: 13))
                .cornerRadius(15)
            }
            .frame(width: geometry.size.width * 0.9)
        }
    }
    
//    List of projects
    private func ProjectList(user: UserInfo, geometry: GeometryProxy) -> some View {
        VStack {
            if let projects = user.projects_users {
                if cursusIndex != -1 {
                    VStack {
                        ForEach(projects.filter {$0.cursus_ids![0] == cursusIndex && $0.status == "finished"}, id: \.id) { project in
                            HStack {
                                if let projectName = project.project?.name {
                                    Text("\(projectName)")
                                }
                                Spacer()
                                if let grade = project.final_mark,
                                   let status = project.validated {
                                    HStack {
                                        Text("\(grade, specifier: "%2.f")")
                                        if status {
                                            Image(systemName: "checkmark")
                                        } else {
                                            Image(systemName: "xmark")
                                        }
                                    }
                                    .foregroundStyle(status ? .green : .red)
                                }
                            }
                            .padding()
                            .frame(width: geometry.size.width * 0.9, height: 50)
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                        }
                    }
                }
            }
        }
    }
//    List of user's achievements
    private func Achievements(user: UserInfo, geometry: GeometryProxy) -> some View {
        return VStack {
            if let achievements = user.achievements {
                VStack {
                    ForEach(achievements, id: \.id) {achievement in
                        HStack {
                            VStack {
                                HStack {
                                    if let name = achievement.name {
                                        Text("\(name)")
                                            .font(.headline)
                                            .font(.system(size: 18))
                                    }
                                    Spacer()
                                }
                                HStack {
                                    if let description = achievement.description {
                                        Text("\(description)")
                                            .font(.system(size: 15))
                                    }
                                    Spacer()
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(width: geometry.size.width * 0.9)
                        .frame(minHeight: 50)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                    }
                }
            }
        }
    }
//    Skills
    private func Skills(user: UserInfo, geometry: GeometryProxy) -> some View {
        return VStack {
            if let skill = user.cursus_users {
                ForEach(skill.filter{$0.cursus_id == CursusToId(cursus: selectedCursus)}, id: \.cursus_id) { result in
                    if let skills = result.skills {
                        if skills.isEmpty {
                            Text("No skills to display")
                        } else {
                            ForEach(skills, id: \.id) {item in
                                if let name = item.name,
                                   let level = item.level{
                                    HStack {
                                        Text("\(name)")
                                        Spacer()
                                        Text("\(level, specifier: "%.2f")%")
                                    }
                                    .padding()
                                    .frame(width: geometry.size.width * 0.9)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(15)
                                }
                            }
                        }
                    }
                }
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
    private func CursusToId(cursus: String) -> Int {
        if let cursusUsers = API.userInfo?.cursus_users {
            for cursusUser in cursusUsers {
                if cursus == cursusUser.cursus?.name {
                    return cursusUser.cursus?.id ?? -1
                }
            }
        }
        return (-1)
    }
}
