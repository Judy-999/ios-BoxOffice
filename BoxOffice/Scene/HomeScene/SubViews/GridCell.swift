//
//  GridCell.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/05.
//

import UIKit

final class GridCell: UICollectionViewCell {
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .systemGray3
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.systemGray3.cgColor
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
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
    
    private let totalAudiencesCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private let openDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    private let currentRankLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.font = .boldSystemFont(ofSize: label.font.pointSize)
        label.textColor = .white
        label.backgroundColor = .black
        label.textAlignment = .center
        label.alpha = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

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
        setOpenDateLabel(with: movie.openDate)
        setupRankChangeLabel(with: movie.rankChange)
        setTotalAudiencesCountLabel(with: movie.totalAudience)
        newEntryBadgeLabel.setupEntryInfo(with: movie.isNewEntry)
        setPosterImageView(with: movie.poster)
    }
    
    private func setOpenDateLabel(with openDate: String) {
        openDateLabel.text = openDate.toDateFormat() + " 개봉"
    }
    
    private func setupRankChangeLabel(with rankChange: String) {
        if let change = Int(rankChange), change != .zero {
            rankChangeBandgeLabel.setupRank(change)
        } else {
            rankChangeBandgeLabel.isHidden = true
        }
    }
    
    private func setTotalAudiencesCountLabel(with totalAudience: String) {
        totalAudiencesCountLabel.text = totalAudience.toDecimal() + "명 관람"
    }
    
    private func setPosterImageView(with image: UIImage?) {
        if let image = image {
            posterImageView.image = image
        } else {
            let image = BoxOfficeImage.posterPlacehorder
            posterImageView.backgroundColor = .systemGray6
            posterImageView.image = image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        rankChangeBandgeLabel.isHidden = false
        posterImageView.image = BoxOfficeImage.posterPlacehorder
        posterImageView.backgroundColor = nil
    }
}

// MARK: Setup Layout
private extension GridCell {
    func addSubViews() {
        badgeStackView.addArrangedSubview(rankChangeBandgeLabel)
        badgeStackView.addArrangedSubview(newEntryBadgeLabel)
        
        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(badgeStackView)
        infoStackView.addArrangedSubview(totalAudiencesCountLabel)
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

