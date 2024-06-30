//
//  ProfileModel.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import Foundation

struct ProfileModel: Codable {
    let userId: Int
    let name: String
    let age: Int
    let profilePicUrl: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name
        case age
        case profilePicUrl = "profile_pic_url"
    }
}
