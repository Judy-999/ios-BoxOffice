//
//  GridCell.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/05.
//

import UIKit

final class GridCell: UICollectionViewCell {
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 2
        return stackView
    }()
    
    private let badgeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.alignment = .top
        stackView.setContentHuggingPriority(.defaultLow, for: .vertical)
        return stackView
    }()
    
    private let totalAudienceLabel: UILabel = {
        let label = MovieLabel(font: .footnote)
        label.textColor = .systemGray
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private let openDateLabel: UILabel = {
        let label = MovieLabel(font: .footnote)
        label.textColor = .systemGray
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    private let currentRankLabel: UILabel = {
        let label = MovieLabel(font: .title2, isBold: true)
        label.textColor = .white
        label.backgroundColor = .black
        label.textAlignment = .center
        label.alpha = 0.8
        return label
    }()
    
    private let posterImageView: UIImageView = PosterImageView()
    private let titleLabel = MovieLabel(font: .title3)
    private let rankChangeBandgeLabel = RankBadgeLabel()
    private let newEntryBadgeLabel = RankBadgeLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with movie: MovieData) {
        titleLabel.text = movie.title
        currentRankLabel.text = movie.currentRank
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
private extension GridCell {
    func addSubViews() {
        badgeStackView.addArrangedSubview(rankChangeBandgeLabel)
        badgeStackView.addArrangedSubview(newEntryBadgeLabel)
        
        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(badgeStackView)
        infoStackView.addArrangedSubview(totalAudienceLabel)
        infoStackView.addArrangedSubview(openDateLabel)
        
        mainStackView.addArrangedSubview(posterImageView)
        mainStackView.addArrangedSubview(infoStackView)
        
        addSubview(mainStackView)
        addSubview(currentRankLabel)
    }
    
    func setupLayout() {
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            currentRankLabel.topAnchor.constraint(equalTo: posterImageView.topAnchor),
            currentRankLabel.leadingAnchor.constraint(equalTo: posterImageView.leadingAnchor),
            currentRankLabel.widthAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 0.2),
            currentRankLabel.heightAnchor.constraint(equalTo: currentRankLabel.widthAnchor),
            
            posterImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
            posterImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
}

