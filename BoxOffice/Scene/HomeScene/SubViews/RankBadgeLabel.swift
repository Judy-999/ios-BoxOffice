//
//  RankChangeLabel.swift
//  BoxOffice
//
//  Created by Judy on 2023/01/22.
//

import UIKit

final class RankBadgeLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel()
    }
    
    func setupRank(_ rankChange: Int) {
        if rankChange > .zero {
            self.text = "  \(rankChange)▲  "
            self.layer.backgroundColor = UIColor.systemGreen.cgColor
        } else {
            self.text = "  \(abs(rankChange))▼  "
            self.layer.backgroundColor = UIColor.systemRed.cgColor
        }
    }
    
    func setupEntryInfo(with isNewEntry: Bool) {
        if isNewEntry {
            self.text = " 신규진입 "
        }
        
        self.layer.backgroundColor = UIColor.systemYellow.cgColor
    }
    
    private func setupLabel() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.font = UIFont.preferredFont(forTextStyle: .footnote)
        self.layer.cornerRadius = 5
    }
}
