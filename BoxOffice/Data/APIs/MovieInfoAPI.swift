//
//  SearchMovieInfoAPI.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/02.
//

import Foundation

struct MovieInfoAPI: API {
    typealias ResponseType = MovieInfoDTO
    
    var configuration: MovieRequest
    
    init(movieCode: String) {
        self.configuration = MovieRequest(
            baseURL: .kobis,
            path: .movieInfo,
            httpMethod: .get,
            query: ["key": Bundle.main.kobisApiKey,
                    "movieCd": movieCode]
        )
    }
}
