//
//  File.swift
//  BoxOffice
//
//  Created by 김주영 on 2023/03/05.
//

struct DailyBoxOfficeDTO: Decodable {
    let boxOfficeResult: BoxOfficeResult
}

struct WeeklyBoxOfficeDTO: Decodable {
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
