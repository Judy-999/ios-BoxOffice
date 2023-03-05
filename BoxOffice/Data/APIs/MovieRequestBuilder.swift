//
//  MovieRequestBuilder.swift
//  BoxOffice
//
//  Created by Judy on 2023/01/20.
//

final class MovieRequestBuilder {
    private var baseURL: BaseURL?
    private var httpMethod: HTTPMethod
    private var path: URLPath?
    private var query: [String: Any]?
    
    init(_ httpMethod: HTTPMethod = .get) {
        self.httpMethod = httpMethod
    }
    
    func setBaseURL(_ url: BaseURL) -> MovieRequestBuilder  {
        self.baseURL = url
        return self
    }
    
    func setMethod(_ method: HTTPMethod) -> MovieRequestBuilder {
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
        guard let baseURL = baseURL,
              let path = path else { return nil }
        
        return MovieRequest(baseURL: baseURL,
                            path: path,
                            httpMethod: httpMethod,
                            query: query)
    }
}
