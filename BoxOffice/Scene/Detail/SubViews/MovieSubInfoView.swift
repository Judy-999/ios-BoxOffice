//
//  MovieSubInfoCollectionViewCell.swift
//  BoxOffice
//
//  Created by Judy on 2023/01/05.
//

import UIKit

final class MovieSubInfoView: UIView {
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let actorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let entireStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let subInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let moreActorsButton: UIButton = {
        let button = MoviewButton(title: ReviewInfo.Phrase.more)
        button.setTitleColor(.systemGray, for: .normal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    private let productionYearLabel = MovieLabel(font: .title3)
    private var ageLimitLabel = MovieLabel(font: .title3)
    private let showTimeLabel = MovieLabel(font: .title3)
    private let totalAudienceLabel = MovieLabel(font: .title3)
    private let directorNameLabel = MovieLabel(font: .body)
    private let actorsLabel = MovieLabel(font: .body)
    
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
    
    func configure(with movie: MovieData) {
        if let ageLimit = AgeLimit(rawValue: movie.ageLimit) {
            ageLimitLabel.text = ageLimit.age
            ageLimitLabel.backgroundColor = ageLimit.color
        } else {
            ageLimitLabel.text = AgeLimit.fullLimit.age
            ageLimitLabel.backgroundColor = AgeLimit.fullLimit.color
        }
        
        productionYearLabel.text = movie.productionYear
        showTimeLabel.text = InfoForm.showTime(movie.showTime).description
        totalAudienceLabel.text = InfoForm.audience(movie.totalAudience.toDecimal()).description
        directorNameLabel.text = InfoForm.director(movie.directorName).description
        actorsLabel.text = InfoForm.actors(movie.actors).description
    }
    
    private func setupView() {
        addSubView()
        setupConstraint()
        totalAudienceLabel.adjustsFontSizeToFitWidth = true
        
        directorNameLabel.textColor = .systemGray
        actorsLabel.textColor = .systemGray
        
        self.backgroundColor = .systemBackground
    }
    
    private func addSubView() {
        infoStackView.addArrangedSubview(productionYearLabel)
        infoStackView.addArrangedSubview(ageLimitLabel)
        infoStackView.addArrangedSubview(showTimeLabel)
        infoStackView.addArrangedSubview(totalAudienceLabel)
        
        subInfoStackView.addArrangedSubview(directorNameLabel)
        subInfoStackView.addArrangedSubview(actorStackView)
        
        actorStackView.addArrangedSubview(actorsLabel)
        actorStackView.addArrangedSubview(moreActorsButton)

        entireStackView.addArrangedSubview(infoStackView)
        entireStackView.addArrangedSubview(subInfoStackView)
        
        self.addSubview(entireStackView)
    }
    
    private func setupConstraint() {
        actorsLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        totalAudienceLabel.setContentHuggingPriority(UILayoutPriority(200), for: .horizontal)
        
        NSLayoutConstraint.activate([
            entireStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor,
                                                 constant: 16),
            entireStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor,
                                                 constant: -16),
            
            entireStackView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}
