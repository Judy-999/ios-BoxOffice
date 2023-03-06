//
//  ListCell.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/03.
//

import UIKit

final class ListCell: UICollectionViewCell {
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private let rankStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        return stackView
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8
        return stackView
    }()

    private let badgeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 8
        stackView.setContentHuggingPriority(.defaultLow, for: .vertical)
        return stackView
    }()
    
    private let totalAudienceLabel: UILabel = {
        let label = MovieLabel(font: .callout)
        label.textColor = .systemGray
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private let openDateLabel: UILabel = {
        let label = MovieLabel(font: .callout)
        label.textColor = .systemGray
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private let posterImageView: UIImageView = PosterImageView()
    private let rankLabel = MovieLabel(font: .title1, isBold: true)
    private let titleLabel = MovieLabel(font: .title2)
    private let rankChangeBandgeLabel = RankBadgeLabel()
    private let newEntryBadgeLabel = RankBadgeLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        contentView.layer.addBottomBorder()
        titleLabel.numberOfLines = 2
        addSubViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with movie: MovieData) {
        titleLabel.text = movie.title
        rankLabel.text = movie.currentRank
        openDateLabel.text = InfoForm.openDate(movie.openDate).description
        setupRankChangeLabel(with: movie.rankChange)
        totalAudienceLabel.text = InfoForm.audience(movie.totalAudience.toDecimal()).description
        newEntryBadgeLabel.setupEntryInfo(with: movie.isNewEntry)
        posterImageView.image = movie.poster
    }
    
    private func setupRankChangeLabel(with rankChange: String) {
        if let change = Int(rankChange), change != .zero {
            rankChangeBandgeLabel.setupRank(change)
        } else {
            rankChangeBandgeLabel.isHidden = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        rankChangeBandgeLabel.isHidden = false
        posterImageView.image = BoxOfficeImage.posterPlacehorder
    }
}

// MARK: Setup Layout
private extension ListCell {
    func addSubViews() {
        badgeStackView.addArrangedSubview(rankChangeBandgeLabel)
        badgeStackView.addArrangedSubview(newEntryBadgeLabel)
        
        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(badgeStackView)
        infoStackView.addArrangedSubview(totalAudienceLabel)
        infoStackView.addArrangedSubview(openDateLabel)
        
        rankStackView.addArrangedSubview(rankLabel)
        
        mainStackView.addArrangedSubview(posterImageView)
        mainStackView.addArrangedSubview(rankStackView)
        mainStackView.addArrangedSubview(infoStackView)
        
        addSubview(mainStackView)
    }
    
    func setupLayout() {
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
                
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor,
                                               constant: 8),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                  constant: -8),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            posterImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            posterImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                                   multiplier: 0.3)
        ])
    }
}

extension CALayer {
    fileprivate func addBottomBorder() {
        let border = CALayer()
        
        border.backgroundColor = UIColor.systemGray3.cgColor
        border.frame = CGRect(x: .zero,
                              y: frame.height - 0.5,
                              width: frame.width,
                              height: 0.5)
        
        self.addSublayer(border)
    }
}
