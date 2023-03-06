//
//  PosterImage.swift
//  BoxOffice
//
//  Created by 김주영 on 2023/03/06.
//

import UIKit

final class PosterImageView: UIImageView {
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupImageView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .scaleAspectFit
        tintColor = .systemGray3
        layer.borderWidth = 1
        layer.cornerRadius = 10
        layer.borderColor = UIColor.systemGray3.cgColor
        clipsToBounds = true
    }
}
