//
//  SearchMovieInfoAPI.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/02.
//

import Foundation

struct MovieInfoAPI: API {
    typealias ResponseType = MovieInfoResponseDTO
    
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

struct MovieInfoResponseDTO: Decodable {
    let movieInfoResult: MovieInfoResult
}

struct MovieInfoResult: Decodable {
    let movieInfo: MovieInfoDTO
}

struct MovieInfoDTO: Decodable {
    let movieCd: String
    let movieNm: String
    let movieNmEn: String
    let showTm: String
    let prdtYear: String
    let openDt: String
    let genres: [Genre]
    let directors: [Director]
    let actors: [Actor]
    let audits: [Audit]
}

struct Genre: Decodable {
    let genreNm: String
}

struct Director: Decodable {
    let peopleNm: String
    let peopleNmEn: String
}

struct Actor: Decodable {
    let peopleNm: String
    let peopleNmEn: String
    let cast: String
    let castEn: String
}

struct Audit: Decodable {
    let auditNo: String
    let watchGradeNm: String
}
