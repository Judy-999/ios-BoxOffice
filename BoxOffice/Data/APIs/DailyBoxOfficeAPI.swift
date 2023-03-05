//
//  SearchDailyBoxOfficeListAPI.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/02.
//

import Foundation

struct DailyBoxOfficeListAPI: API {
    typealias ResponseType = DailyBoxOfficeDTO
    
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
