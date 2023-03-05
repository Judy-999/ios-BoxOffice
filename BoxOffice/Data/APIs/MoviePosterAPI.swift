//
//  SearchMoviePosterAPI.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/02.
//

import Foundation

struct MoviePosterAPI: API {
    typealias ResponseType = MoviePosterDTO
    
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
