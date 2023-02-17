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
        stackView.alignment = .top
        return stackView
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(UILayoutPriority(100), for: .vertical)
        return label
    }()
    
    private let badgeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()
    
    private let totalAudiencesCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        return label
    }()
    
    private let openDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        return label
    }()

    private let fakeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 10).isActive = true
        view.heightAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true
        view.setContentHuggingPriority(.init(100), for: .vertical)
        return view
    }()

    private let currentRankLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.font = .boldSystemFont(ofSize: label.font.pointSize)
        label.textColor = .white
        label.backgroundColor = .black
        label.textAlignment = .center
        label.alpha = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

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
    
    func setup(with data: MovieData) {
        titleLabel.text = data.title
        currentRankLabel.text = data.currentRank
        setOpenDateLabel(with: data.openDate)
        setupRankChangeLabel(with: data.rankChange)
        setTotalAudiencesCountLabel(with: data.totalAudience)
        newEntryBadgeLabel.setupEntryInfo(with: data.isNewEntry)
        setPosterImageView(with: data.poster)
    }
    
    private func setOpenDateLabel(with openDate: String) {
        let characterArray = Array(openDate).map { String($0) }
        let date = characterArray[0...3].joined()
        + "-"
        + characterArray[4...5].joined()
        + "-" + characterArray[6...7].joined()
        + " 개봉"
        
        openDateLabel.text = date
    }
    
    private func setupRankChangeLabel(with rankChange: String) {
        if let change = Int(rankChange), change != .zero {
            rankChangeBandgeLabel.setupRank(change)
        } else {
            rankChangeBandgeLabel.isHidden = true
        }
    }
    
    private func setTotalAudiencesCountLabel(with totalAudience: String) {
        totalAudiencesCountLabel.text = "관객수 " + totalAudience.toDecimal() + "명"
    }
    
    private func setPosterImageView(with image: UIImage?) {
        if let image = image {
            posterImageView.image = image
        } else {
            let image = UIImage(systemName: "nosign")
            posterImageView.backgroundColor = .systemGray6
            posterImageView.image = image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        rankChangeBandgeLabel.isHidden = false
        posterImageView.image = UIImage(systemName: "nosign")
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
        infoStackView.addArrangedSubview(fakeView)
        
        mainStackView.addArrangedSubview(posterImageView)
        mainStackView.addArrangedSubview(infoStackView)
        
        addSubview(mainStackView)
        addSubview(currentRankLabel)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            currentRankLabel.topAnchor.constraint(equalTo: posterImageView.topAnchor),
            currentRankLabel.leadingAnchor.constraint(equalTo: posterImageView.leadingAnchor),
            currentRankLabel.widthAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1/5),
            currentRankLabel.heightAnchor.constraint(equalTo: currentRankLabel.widthAnchor),
            
            posterImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 7/10),
            posterImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
}

