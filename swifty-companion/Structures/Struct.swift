//
//  Untitled.swift
//  swifty-companion
//
//  Created by Artur Harutyunyan on 18.03.25.
//

struct Credentials : Codable {
    var uid: String
    var secret: String
    var url: String
}

struct TokenValue : Codable {
    var access_token: String
}

struct Versions : Codable {
    var small: String?
    var medium: String?
}

struct UserImage: Codable {
    var link: String?
    var versions: Versions?
}

struct Cursus : Codable {
    var name: String?
    var id: Int?
}

struct User : Codable {
    var displayname: String?
    var login: String?
    var wallet: Int?
    var location: String?
    var correction_point: Int?
    var image: UserImage?
}

struct Project : Codable {
    var name: String?
}

struct ProjectsUsers: Codable {
    var id: Int?
    var final_mark: Double?
    var cursus_ids: [Int]?
    var status: String?
    var validated: Bool?
    var project: Project?

    enum CodingKeys: String, CodingKey {
        case id
        case final_mark
        case cursus_ids
        case status
        case validated = "validated?"
        case project
    }
}

struct Achievements : Codable {
    var description: String?
    var id: Int?
    var kind: String?
    var name: String?
    var image: String?
}


struct CursusUsers : Codable {
    var cursus_id: Int?
    var level: Double?
    var user: User?
    var cursus: Cursus?
}


struct UserInfo : Codable {
    var cursus_users: [CursusUsers]?
    var projects_users: [ProjectsUsers]?
    var achievements: [Achievements]?
}
