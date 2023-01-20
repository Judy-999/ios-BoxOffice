//
//  MovieRequestBuilder.swift
//  BoxOffice
//
//  Created by Judy on 2023/01/20.
//

final class MovieRequestBuilder {
    private var baseURL: BaseURL
    private var httpMethod: String
    private var path: URLPath
    private var query: [String: Any]
    
    private init(baseURL: BaseURL, httpMethod: String, path: URLPath, query: [String : Any]) {
        self.baseURL = baseURL
        self.httpMethod = httpMethod
        self.path = path
        self.query = query
    }
    
    func setBaseURL(_ url: BaseURL) -> MovieRequestBuilder  {
        self.baseURL = url
        return self
    }
    
    func setMethod(_ method: String) -> MovieRequestBuilder {
        self.httpMethod = method
        return self
    }
    
    func setPath(_ path: URLPath) -> MovieRequestBuilder {
        self.path = path
        return self
    }
    
    func setQuery(_ query: [String: Any]) -> MovieRequestBuilder {
        self.query = query
        return self
    }
    
    func buildRequest() -> MovieRequest? {
        return MovieRequest(baseUrl: baseURL,
                            query: query,
                            path: path,
                            httpMethod: httpMethod)
    }
}
