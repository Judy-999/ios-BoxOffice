//
//  String+Extension.swift
//  BoxOffice
//
//  Created by 김주영 on 2023/02/17.
//

import Foundation

extension String {
    func toDecimal() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        if let number = Int(self),
           let numberToDecimal = numberFormatter.string(
            from: NSNumber(integerLiteral: number)
           ) {
            return numberToDecimal
        }
        
        return self
    }
    
    func toDateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        }
   
        return self
    }
}
