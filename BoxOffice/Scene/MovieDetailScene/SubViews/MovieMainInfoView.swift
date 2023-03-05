//
//  MovieMainInfoCollectionViewCell.swift
//  BoxOffice
//
//  Created by Judy on 2023/01/05.
//

import UIKit

final class MovieMainInfoView: UIView {
    private let rankStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let subInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.setContentHuggingPriority(.defaultLow, for: .vertical)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let ratingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let entireStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let posterView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let starView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ReviewInfo.Rating.fillStarImage
        imageView.tintColor = .systemYellow
        imageView.contentMode = .scaleAspectFit
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = MovieLabel(font: .title1, isBold: true)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let currentRankLabel: UILabel = {
        let label = MovieLabel(font: .largeTitle, isBold: true)
        label.textColor = .white
        label.backgroundColor = .black
        label.textAlignment = .center
        label.alpha = 0.8
        return label
    }()
    
    private let separatorLabel: UILabel = {
        let label = MovieLabel(font: .body, isBold: true)
        label.text = " • "
        return label
    }()
    
    private let openYearLabel = MovieLabel(font: .body)
    private let genreLabel = MovieLabel(font: .body)
    private let ratingLabel = MovieLabel(font: .title3)
    private let rankChangeBandgeLabel = RankBadgeLabel()
    private let newEntryBadgeLabel = RankBadgeLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func draw(_ rect: CGRect) {
        let separator = UIBezierPath()
        separator.move(to: CGPoint(x: 0, y: bounds.maxY))
        separator.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        separator.lineWidth = 8
        UIColor.systemGray5.setStroke()
        separator.stroke()
        separator.close()
    }
    
    func configure(with movie: MovieData, rating: String) {
        posterView.image = movie.poster
        ratingLabel.text = InfoForm.rating(rating).description
        titleLabel.text = movie.title
        currentRankLabel.text = movie.currentRank
        setupRankChangeLabel(with: movie.rankChange)
        newEntryBadgeLabel.setupEntryInfo(with: movie.isNewEntry)
        openYearLabel.text = movie.openYear
        genreLabel.text = movie.genreName
    }
    
    private func setupRankChangeLabel(with rankChange: String) {
        if let change = Int(rankChange), change != .zero {
            rankChangeBandgeLabel.setupRank(change)
        } else {
            rankChangeBandgeLabel.isHidden = true
        }
    }
    
    private func setupView() {
        addSubView()
        setupConstraint()
        self.backgroundColor = .systemBackground
    }
    
    private func addSubView() {
        rankStackView.addArrangedSubview(rankChangeBandgeLabel)
        rankStackView.addArrangedSubview(newEntryBadgeLabel)
        
        subInfoStackView.addArrangedSubview(openYearLabel)
        subInfoStackView.addArrangedSubview(separatorLabel)
        subInfoStackView.addArrangedSubview(genreLabel)
        
        ratingStackView.addArrangedSubview(starView)
        ratingStackView.addArrangedSubview(ratingLabel)
        
        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(subInfoStackView)
        infoStackView.addArrangedSubview(rankStackView)
        infoStackView.addArrangedSubview(ratingStackView)
        
        entireStackView.addArrangedSubview(posterView)
        entireStackView.addArrangedSubview(infoStackView)
        
        self.addSubview(entireStackView)
        self.addSubview(currentRankLabel)
    }

    private func setupConstraint() {
        NSLayoutConstraint.activate([
            currentRankLabel.topAnchor.constraint(equalTo: posterView.topAnchor),
            currentRankLabel.leadingAnchor.constraint(equalTo: posterView.leadingAnchor),
            currentRankLabel.widthAnchor.constraint(equalTo: posterView.widthAnchor, multiplier: 1/5),
            currentRankLabel.heightAnchor.constraint(equalTo: currentRankLabel.widthAnchor),
            
            entireStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                                 constant: 8),
            entireStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -8),
            entireStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor,
                                                     constant: 16),
            entireStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor,
                                                      constant: -16),
            
            posterView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor,
                                              multiplier: 2/5),
            starView.widthAnchor.constraint(equalTo: starView.heightAnchor)
        ])
    }
    
}
