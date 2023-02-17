//
//  String+Extension.swift
//  BoxOffice
//
//  Created by 김주영 on 2023/02/17.
//

import Foundation

extension String {
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }
    
    func toDecimal() -> String {
        guard let number = Int(self) else { return "" }
        return numberFormatter.string(from: NSNumber(integerLiteral: number)) ?? ""
    }
}
