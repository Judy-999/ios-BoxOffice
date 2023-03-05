//
//  MovieInfoDTO.swift
//  BoxOffice
//
//  Created by 김주영 on 2023/03/05.
//

struct MovieInfoDTO: Decodable {
    let movieInfoResult: MovieInfoResult
}

struct MovieInfoResult: Decodable {
    let movieInfo: MovieInfo
}

struct MovieInfo: Decodable {
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
