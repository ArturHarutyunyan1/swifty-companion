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

struct User : Codable {
    var displayname: String?
    var login: String?
    var wallet: Int?
    var location: String?
    var correction_point: Int?
    var image: UserImage?
}

struct CursusUsers : Codable {
    var cursus_id: Int?
    var user: User?
}


struct UserInfo : Codable {
    var cursus_users: [CursusUsers]?
}
