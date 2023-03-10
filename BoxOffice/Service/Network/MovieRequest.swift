//
//  APIConfiguration.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/02. -> Refacted by Judy on 2023/01/21.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
}

enum BaseURL: String {
    case kobis = "https://www.kobis.or.kr/kobisopenapi/webservice/rest"
    case omdb = "https://www.omdbapi.com"
}

enum URLPath: String {
    case dailyBoxOffice = "/boxoffice/searchDailyBoxOfficeList.json"
    case weeklyBoxOffice = "/boxoffice/searchWeeklyBoxOfficeList.json"
    case movieInfo = "/movie/searchMovieInfo.json"
    case empty = ""
}

protocol APIRequest {
    var baseURL: BaseURL { get }
    var httpMethod: HTTPMethod { get }
    var path: URLPath { get }
    var query: [String : Any]? { get }
}

extension APIRequest {
    var url: URL? {
        var urlComponents = URLComponents(string: baseURL.rawValue + path.rawValue)
        
        if let query = query {
            urlComponents?.queryItems = query.map {
                URLQueryItem(name: $0.key,
                             value: "\($0.value)")
            }
        }
        
        return urlComponents?.url
    }
    
    var urlRequest: URLRequest? {
        guard let url = url else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        
        return urlRequest
    }
}

struct MovieRequest: APIRequest {
    let baseURL: BaseURL
    let path: URLPath
    let httpMethod: HTTPMethod
    let query: [String : Any]?
    
    init(
        baseURL: BaseURL,
        path: URLPath = URLPath.empty,
        httpMethod: HTTPMethod = HTTPMethod.get,
        query: [String : Any]?
    ) {
        self.baseURL = baseURL
        self.query = query
        self.path = path
        self.httpMethod = httpMethod
    }
}
