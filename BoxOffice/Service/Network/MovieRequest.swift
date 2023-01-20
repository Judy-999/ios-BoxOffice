//
//  APIConfiguration.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/02.
//

import Foundation

enum HTTPMethod {
    static let get = "GET"
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
    var httpMethod: String { get }
    var baseURL: String { get }
    var path: String { get }
    var query: [URLQueryItem] { get }
}

struct MovieRequest: APIRequest {
    let baseURL: String
    let query: [URLQueryItem]
    let path: String
    let httpMethod: String
    
    init(
        baseUrl: BaseURL,
        query: [String : Any],
        path: URLPath = URLPath.empty,
        httpMethod: String = HTTPMethod.get
    ) {
        self.baseURL = baseUrl.rawValue
        self.query = query.queryItems
        self.path = path.rawValue
        self.httpMethod = httpMethod
    }
    
    func makeURLRequest() -> URLRequest? {
        guard var urlComponent = URLComponents(string: baseURL + path) else { return nil }
        urlComponent.queryItems = query
        guard let url = urlComponent.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }
}
