//
//  SearchWeeklyBoxOfficeListAPI.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/02.
//

import Foundation

enum WeekOption: String {
    case allWeek = "0"
    case weekEnd = "1"
    case weekDays = "2"
}

struct WeeklyBoxOfficeListAPI: API {
    typealias ResponseType = WeeklyBoxOfficeDTO
    
    var configuration: MovieRequest
    
    init(date: String, itemPerPage: String = "10", weekOption: WeekOption) {
        
        self.configuration = MovieRequest(
            baseURL: .kobis,
            path: .weeklyBoxOffice,
            httpMethod: .get,
            query: ["key": Bundle.main.kobisApiKey,
                    "targetDt": date,
                    "weekGb": weekOption.rawValue,
                    "wideAreaCd": "0105001",
                    "itemPerPage": itemPerPage]
        )
    }
}
