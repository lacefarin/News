//
//  FetchedObject.swift
//  News
//
//  Created by Luka Cefarin on 08/01/2021.
//

import Foundation

struct FetchedObjectDTO: Decodable {
    let data: DataObjectDTO
}

struct DataObjectDTO: Decodable {
    let front: FrontObjectDTO
}

struct FrontObjectDTO: Decodable {
    let data: [FrontDataObjectDTO]
}

struct FrontDataObjectDTO: Decodable {
    let payload: [NewsObjectDTO]
}

struct NewsObjectDTO: Decodable {
    let __typename: String?
    let title: String?
    let frontImage: FrontImageDTO?
    
    func toDomain(withArticleType articleType: String, imageWidth width: Int, andHeight height: Int) -> NewsObject? {
        guard __typename == articleType, let title = title, let frontImage = frontImage else {
            return nil
        }
        let imageResolutionPlaceholder: String = "PLACEHOLDER"
        let imageResolution: String = "\(width)x\(height)"
        let urlWithImageResolution: String = frontImage.src.replacingOccurrences(of: imageResolutionPlaceholder, with: imageResolution)
        let imageUrl: URL? = URL(string: urlWithImageResolution)
        return .init(title: title, imageUrl: imageUrl)
    }
}

struct FrontImageDTO: Decodable {
    let src: String
}
