//
//  BoxOfficeInfo.swift
//  BoxOffice
//
//  Created by 김주영 on 2023/02/27.
//

import UIKit

enum InfoForm {
    case showTime(String)
    case audience(String)
    case director(String)
    case actors([String])
    case rating(String)
    case openDate(String)
    
    var description: String {
        switch self {
        case .showTime(let time):
            return time + "분"
        case .audience(let audience):
            return audience + "명 관람"
        case .director(let director):
            return "감독: " + director
        case .actors(let actors):
            return "출연: " + actors.joined(separator: ", ")
        case .rating(let rating):
            return rating == "nan" ? "정보 없음" : rating
        case .openDate(let date):
            return date + " 개봉"
        }
    }
}

enum BoxOfficeImage {
    static let posterPlacehorder = UIImage(systemName: "nosign")
    static let photoPlacehorder = UIImage(systemName: "photo.on.rectangle.angled")
    static let calendar = UIImage(systemName: "calendar")
    static let checkMark = UIImage(systemName: "checkmark")
    static let share = UIImage(systemName: "square.and.arrow.up")
}
