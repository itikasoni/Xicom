//
//  ImgListingModel.swift
//  Xicom M Test
//
//  Created by Itika Soni on 13/09/23.
//


import Foundation

// MARK: - ImageListingModel
struct ImageListingModel: Codable {
    let message: String?
    let status: String?
    let images: [Image]?
}

// MARK: - Image
struct Image: Codable {
    let xtImage: String?
    let id: String?

    enum CodingKeys: String, CodingKey {
        case xtImage = "xt_image"
        case id
    }
}

