//
//  ApiManager.swift
//  swifty-companion
//
//  Created by Artur Harutyunyan on 18.03.25.
//

import Foundation
import SwiftUI

class ApiManager : ObservableObject {
    @Published var userInfo: UserInfo?
    
    func searchUser(username: String) {
        let url = URL(string: "https://api.intra.42.fr/v2/users/\(username)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "access_token") ?? "")", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let error = error {
                print("Error - \(error)")
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    print("Something went wrong - \(response.statusCode)")
                }
            }
            if let data = data {
                do {
                    let decoder = try JSONDecoder().decode(UserInfo.self, from: data)
                    DispatchQueue.main.async {
                        self.userInfo = decoder
                        print(self.userInfo)
                    }
                } catch {
                    print("Error - \(error)")
                }
            }
        }.resume()
    }
}
