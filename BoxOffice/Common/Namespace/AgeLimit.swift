//
//  AgeLimit.swift
//  BoxOffice
//
//  Created by 김주영 on 2023/03/02.
//

import UIKit

enum AgeLimit: String {
    case all = "전체관람가"
    case twelveOver = "12세이상관람가"
    case fifteenOver = "15세이상관람가"
    case teenagersNotAllowed = "청소년관람불가"
    case fullLimit = "제한상영가"
    
    var age: String {
        switch self {
        case .all:
            return " ALL "
        case .twelveOver:
            return " 12 "
        case .fifteenOver:
            return " 15 "
        case .teenagersNotAllowed:
            return " 18 "
        case .fullLimit:
            return " X "
        }
    }
    
    var color: UIColor {
        switch self {
        case .all:
            return .systemGreen
        case .twelveOver:
            return .systemYellow
        case .fifteenOver:
            return .systemOrange
        case .teenagersNotAllowed:
            return .systemRed
        case .fullLimit:
            return .black
        }
    }
}
