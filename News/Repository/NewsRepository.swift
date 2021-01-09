//
//  NewsRepository.swift
//  News
//
//  Created by Luka Cefarin on 08/01/2021.
//

import Foundation


struct NewsRepository {
    
    enum FetchError: Error {
        case invalidNewsUrl
        case requestFailed
        case decodingNewsDataFailed
    }
    
    struct FetchParameters {
        var articleType: String = "ArticleSlim"
        var imageWidth: Int = 160
        var imageHeight: Int = 90
    }
    
    private let newsUrl: URL? = URL(string: "https://gqlc.24ur.com/graphql/?raw&query=onl_web_basic_front(url:%20%22/%22%20siteId:%201)")
    
    @discardableResult
    func fetchNews(withParameters fetchParameters: FetchParameters, completion: @escaping (Result<[NewsObject], FetchError>) -> Void) -> URLSessionDataTask? {
        
        // Make sure that news url is correct
        guard let url = newsUrl else {
            completion(.failure(.invalidNewsUrl))
            return nil
        }
        
        // Create url request with news url
        let request: URLRequest = URLRequest(url: url)
        
        let dataTask: URLSessionDataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse, let data = data, (200...299).contains(httpResponse.statusCode), error == nil else {
                completion(.failure(.requestFailed))
                return
            }
            
            if let fetchedObject = try? JSONDecoder().decode(FetchedObjectDTO.self, from: data) {
                let newsObjectsDTO: [NewsObjectDTO] = fetchedObject.data.front.data.map { $0.payload }.flatMap { $0 }
                let newsObjects: [NewsObject] = newsObjectsDTO.map { $0.toDomain(withArticleType: fetchParameters.articleType, imageWidth: fetchParameters.imageWidth, andHeight: fetchParameters.imageHeight) }.compactMap { $0 }
                completion(.success(newsObjects))
            } else {
                completion(.failure(.decodingNewsDataFailed))
            }
        }
        
        // Start task
        dataTask.resume()
        
        return dataTask
    }
    
}
