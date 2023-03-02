//
//  StarRatingView.swift
//  BoxOffice
//
//  Created by Judy on 2023/01/03.
//

import UIKit

final class StarRatingView: UIView {
    private let starImages = (1...5).map { _ in StarImageView(frame: .zero) }
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.text = "0.0"
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: label.font.pointSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starSlider: StarRatingUISlider = {
        let slider = StarRatingUISlider()
        slider.maximumValue = 5.0
        slider.minimumValue = 0.0
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
        slider.thumbTintColor = .clear
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let starStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let entireStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var rating: String? {
        return ratingLabel.text
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addSliderTarget()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        addSliderTarget()
    }

    @objc private func sliderStar() {
        let rating = starSlider.value
        var ratingValue = rating.rounded(.down)
        let halfRating = rating - ratingValue
        let rateIndex = Int(ratingValue)

        clearStar()
        fillStar(upto: rateIndex)

        if halfRating >= ReviewInfo.Rating.halfValue {
            starImages[rateIndex].image = ReviewInfo.Rating.halfStarImage
            ratingValue += ReviewInfo.Rating.halfValue
        }
        
        ratingLabel.text = String(format: "%.1f", ratingValue)
    }

    private func fillStar(upto index: Int) {
        for fillIndex in Int.zero..<index {
            starImages[fillIndex].image = ReviewInfo.Rating.fillStarImage
        }
    }

    private func clearStar() {
        starImages.forEach {
            $0.image = ReviewInfo.Rating.emptyStarImage
        }
    }
    
    private func addSliderTarget() {
        starSlider.addTarget(self,
                             action: #selector(sliderStar),
                             for: .valueChanged)
    }
}

//MARK: Setup View
extension StarRatingView {
    private func setupView() {
        addSubView()
        setupConstraint()
    }
    
    private func addSubView() {
        starImages.forEach {
            starStackView.addArrangedSubview($0)
        }
        
        entireStackView.addArrangedSubview(starStackView)
        entireStackView.addArrangedSubview(ratingLabel)
        
        self.addSubview(entireStackView)
        self.addSubview(starSlider)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            entireStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            entireStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            entireStackView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            entireStackView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor,
                                                   multiplier: 4/5),
            
            starStackView.heightAnchor.constraint(equalTo: starStackView.widthAnchor,
                                                  multiplier: 1/5),
            ratingLabel.widthAnchor.constraint(equalTo: starStackView.widthAnchor,
                                               multiplier: 1/4),
            
            starSlider.centerYAnchor.constraint(equalTo: centerYAnchor),
            starSlider.leadingAnchor.constraint(equalTo: entireStackView.leadingAnchor),
            starSlider.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor,
                                              multiplier: 3/5)
        ])
    }
}
