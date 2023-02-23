//
//  SearchMoviePosterAPI.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/02.
//

import Foundation

struct MoviePosterAPI: API {
    typealias ResponseType = MoviePosterResponseDTO
    
    var configuration: MovieRequest
    
    init(movieTitle: String, year: String? = nil) {
        if let year = year {
            self.configuration = MovieRequest(
                baseURL: .omdb,
                path: .empty,
                httpMethod: .get,
                query: ["apikey": Bundle.main.omdbApiKey,
                        "s": movieTitle,
                        "y": year]
            )
        } else {
            self.configuration = MovieRequest(
                baseURL: .omdb,
                path: .empty,
                httpMethod: .get,
                query: ["apikey": Bundle.main.omdbApiKey,
                        "s": movieTitle]
            )
        }
    }
}

struct MoviePosterResponseDTO: Decodable {
    let search: [MovieDTO]
    let totalResults: String
    let response: String
    
    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case response = "Response"
    }
    
    var posterURL: String? {
        guard let posterURL = search.first?.poster else { return nil }
        
        return posterURL.count < 10 ? nil : posterURL
    }
}

struct MovieDTO: Decodable {
    let title: String
    let year: String
    let imdbID: String
    let type: String
    let poster: String
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
        case type = "Type"
        case poster = "Poster"
    }
}
