//
//  SearchDailyBoxOfficeListAPI.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/02.
//

import Foundation

struct DailyBoxOfficeListAPI: API {
    typealias ResponseType = DailyBoxOfficeListResponseDTO
    
    var configuration: MovieRequest
    
    init(date: String, itemPerPage: String = "10") {
        self.configuration = MovieRequest(
            baseURL: .kobis,
            path: .dailyBoxOffice,
            httpMethod: .get,
            query: ["key": Bundle.main.kobisApiKey,
                    "targetDt": date,
                    "wideAreaCd": "0105001",
                    "itemPerPage": itemPerPage]
        )
    }
}

struct DailyBoxOfficeListResponseDTO: Decodable {
    let boxOfficeResult: BoxOfficeResult
}

struct BoxOfficeResult: Decodable {
    let boxofficeType: String
    let showRange: String
    let yearWeekTime: String?
    let dailyBoxOfficeList: [BoxOfficeDTO]?
    let weeklyBoxOfficeList: [BoxOfficeDTO]?
}

struct BoxOfficeDTO: Decodable {
    let rnum: String
    let rank: String
    let rankInten: String
    let rankOldAndNew: String
    let movieCd: String
    let movieNm: String
    let audiAcc: String
}