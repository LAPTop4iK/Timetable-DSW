//
//  public.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 21/10/2025.
//


// ===== FILE: Services/Ads/Native/NativeAdViewClasses.swift =====

import GoogleMobileAds
import UIKit
import LBTATools
import SwiftUI

// MARK: - NativeAdViewStyle enum

public enum NativeAdViewStyle {
    /// у меня неправильный
    case basic
        /// баннер с кнопкой и видео
    case card
        /// обычный баннер
    case banner
        /// странный, как будто только для горизонтали
    case largeBanner
    
    var view: NativeAdView {
        switch self {
        case .basic:
            return NativeAdBasicView1(frame: .zero)
        case .card:
            return NativeAdCardView1(frame: .zero)
        case .banner:
            return NativeAdBannerView(frame: .zero)
        case .largeBanner:
            return NativeLargeAdBannerView(frame: .zero)
        }
    }
}

// MARK: - NativeAdCardView (главный стиль)

class NativeAdCardView: NativeAdView {
    
    let adTag: UILabel = UILabel(text: "AD", font: .systemFont(ofSize: 10, weight: .semibold), textColor: .white)
    let headlineLabel = UILabel(text: "", font: .systemFont(ofSize: 17, weight: .medium), textColor: .label)
    let myMediaView = MediaView()
    let callToActionButton = UIButton(title: "", titleColor: .white, font: .boldSystemFont(ofSize: 18), backgroundColor: UIColor(hex: "#3871E0"), target: nil, action: nil)
    let iconImageView = UIImageView()
    let bodyLabel = UILabel(text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: .label)
    let starRatingImageView = UIImageView()
    let advertiserLabel = UILabel(text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: .label)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        self.headlineView = headlineLabel
        self.advertiserView = advertiserLabel
        
        myMediaView.translatesAutoresizingMaskIntoConstraints = false
        myMediaView.heightAnchor.constraint(equalTo: myMediaView.widthAnchor, multiplier: 9.0/16.0).isActive = true
        self.mediaView = myMediaView
        
        callToActionButton.isUserInteractionEnabled = false
        callToActionButton.layer.cornerRadius = 8
        callToActionButton.clipsToBounds = true
        self.callToActionView = callToActionButton
        
        iconImageView.layer.cornerRadius = 4
        iconImageView.clipsToBounds = true
        iconImageView.withWidth(40).withHeight(40)
        self.iconView = iconImageView
        
        bodyLabel.numberOfLines = 2
        bodyLabel.isUserInteractionEnabled = false
        bodyLabel.textColor = .secondaryLabel
        self.bodyView = bodyLabel
        
        starRatingImageView.withWidth(100).withHeight(17)
        self.starRatingView = starRatingImageView
        
        adTag.withWidth(25)
        adTag.textAlignment = .center
        adTag.backgroundColor = UIColor(hex: "FFCC66")
        adTag.layer.cornerRadius = 2
        adTag.clipsToBounds = true
        adTag.text = "AD"
        
        // ТОЧНАЯ ВЕРСТКА из рабочего примера
        let starRattingStack = hstack(adTag, starRatingImageView, advertiserLabel, UIView(), spacing: 4)
        let headlineStarStack = stack(headlineLabel, starRattingStack, spacing: 8)
        let iconHeadlineStack = hstack(stack(iconImageView), headlineStarStack, UIView(), spacing: 8)
        let buttonStack = hstack(callToActionButton.withHeight(39)).withMargins(.init(top: 0, left: 10, bottom: 0, right: 10))
        let bottomStack = stack(iconHeadlineStack, bodyLabel, buttonStack, spacing: 8).withMargins(.allSides(10))
        stack(myMediaView, bottomStack)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NativeAdCardView1: NativeAdView {

    let adTag: UILabel = UILabel(text: "AD", font: .systemFont(ofSize: 10, weight: .semibold), textColor: .white)
    let headlineLabel = UILabel(text: "", font: .systemFont(ofSize: 17, weight: .medium), textColor: .label)
    let myMediaView = MediaView()
    let callToActionButton = UIButton(title: "", titleColor: .white, font: .boldSystemFont(ofSize: 18), backgroundColor: UIColor(hex: "#3871E0"), target: nil, action: nil)
    let iconImageView = UIImageView()
    let bodyLabel = UILabel(text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: .label)
    let advLabel = UILabel(text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: .label)
    let storeLabel = UILabel(text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: .label)
    let starRatingImageView = UIImageView()
//    let advertiserLabel = UILabel(text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: .label)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    func setupViews() {
        self.headlineView = headlineLabel

        myMediaView.translatesAutoresizingMaskIntoConstraints = false
        myMediaView.heightAnchor.constraint(equalTo: myMediaView.widthAnchor, multiplier: 9.0/16.0).isActive = true
        self.mediaView = myMediaView

        callToActionButton.isUserInteractionEnabled = false
        callToActionButton.layer.cornerRadius = 8
        callToActionButton.clipsToBounds = true
        callToActionButton.withHeight(39)
        self.callToActionView = callToActionButton

        iconImageView.layer.cornerRadius = 4
        iconImageView.clipsToBounds = true
        iconImageView.withWidth(90).withHeight(90)
        self.iconView = iconImageView

//        advLabel.numberOfLines = 2
//        advLabel.isUserInteractionEnabled = false
//        advLabel.textColor = .secondaryLabel
        self.advertiserView = advLabel
        self.storeView = storeLabel

        bodyLabel.numberOfLines = 2
        bodyLabel.isUserInteractionEnabled = false
        bodyLabel.textColor = .secondaryLabel
        self.bodyView = bodyLabel

        bodyLabel.numberOfLines = 2
        bodyLabel.isUserInteractionEnabled = false
        bodyLabel.textColor = .secondaryLabel
        self.bodyView = bodyLabel

//        starRatingImageView.withWidth(100).withHeight(17)
        starRatingImageView.withHeight(17)
        starRatingImageView.contentMode = .left
        self.starRatingView = starRatingImageView

        adTag.withWidth(25)
        adTag.textAlignment = .center
        adTag.backgroundColor = UIColor(hex: "FFCC66")
        adTag.layer.cornerRadius = 2
        adTag.clipsToBounds = true
        adTag.text = "AD"

        // ТОЧНАЯ ВЕРСТКА из рабочего примера
//        let starRattingStack = hstack(adTag, starRatingImageView, advertiserLabel, UIView(), spacing: 4)
//        let headlineStarStack = stack(headlineLabel, starRattingStack, spacing: 8)
//        let iconHeadlineStack = hstack(stack(iconImageView), headlineStarStack, UIView(), spacing: 8)
//        let buttonStack = hstack(callToActionButton.withHeight(39)).withMargins(.init(top: 0, left: 10, bottom: 0, right: 10))
//        let bottomStack = stack(iconHeadlineStack, bodyLabel, buttonStack, spacing: 8).withMargins(.allSides(10))
//        stack(myMediaView, bottomStack)

        let adOrStoreStack = hstack(advLabel, storeLabel, spacing: 8)
        let adStack = hstack(adTag, starRatingImageView, spacing: 8)
        let infoStack = stack(adStack, headlineLabel, adOrStoreStack).withMargins(.init(top: 0, left: 16, bottom: 8, right: 16))

        let imageInfoStack = hstack(iconImageView, infoStack)
//        let topStack = stack(imageInfoStack, bodyLabel)
        stack(imageInfoStack, bodyLabel, myMediaView, callToActionButton, distribution: .equalSpacing)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - NativeAdBannerView (горизонтальный)

class NativeAdBannerView: NativeAdView {
    
    let adTag: UILabel = UILabel(text: "AD", font: .systemFont(ofSize: 11, weight: .semibold), textColor: .white, textAlignment: .center)
    let headlineLabel = UILabel(text: "", font: .systemFont(ofSize: 15, weight: .medium), textColor: .label)
    let iconImageView = UIImageView()
    let bodyLabel = UILabel(text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: .secondaryLabel)
    let starRatingImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        self.headlineView = headlineLabel
        self.iconView = iconImageView
        self.bodyView = bodyLabel
        
        adTag.withWidth(20)
        adTag.backgroundColor = UIColor(hex: "FFCC66")
        adTag.layer.cornerRadius = 2
        adTag.clipsToBounds = true
        
        // config 1:1
        iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor, multiplier: 1).isActive = true
        iconImageView.layer.cornerRadius = 4
        iconImageView.clipsToBounds = true
        
        headlineLabel.numberOfLines = 1
        headlineLabel.lineBreakMode = .byWordWrapping
        
        bodyLabel.numberOfLines = 2
        bodyLabel.lineBreakMode = .byWordWrapping
        
        // ТОЧНАЯ ВЕРСТКА из рабочего примера
        let headerStack = hstack(headlineLabel, adTag)
        let leftStack = stack(headerStack, bodyLabel)
        
        hstack(leftStack, iconImageView, spacing: 8).withMargins(.allSides(8))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - NativeLargeAdBannerView (большой горизонтальный)

class NativeLargeAdBannerView: NativeAdView {
    // require
    let myMediaView = MediaView()
    let headlineLabel = UILabel(text: "", font: .systemFont(ofSize: 15, weight: .medium), textColor: .label, numberOfLines: 2)
    let adTag: UILabel = UILabel(text: "AD", font: .systemFont(ofSize: 10, weight: .semibold), textColor: .secondaryLabel, textAlignment: .center)
    
    // for web
    let advertiserLabel = UILabel(text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: .secondaryLabel, numberOfLines: 1)
    let bodyLabel = UILabel(text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: .secondaryLabel, numberOfLines: 3)
    
    // for app
    let callToActionButton = UIButton(title: "", titleColor: .label, font: .boldSystemFont(ofSize: 14), backgroundColor: .systemBlue, target: nil, action: nil)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        myMediaView.translatesAutoresizingMaskIntoConstraints = false
        myMediaView.widthAnchor.constraint(equalTo: myMediaView.heightAnchor, multiplier: 16/9).isActive = true
        myMediaView.contentMode = .scaleAspectFill
        myMediaView.clipsToBounds = true
        self.mediaView = myMediaView

        self.headlineView = headlineLabel
        self.advertiserView = advertiserLabel
        self.bodyView = bodyLabel
        
        callToActionButton.isUserInteractionEnabled = false
        callToActionButton.layer.cornerRadius = 8
        callToActionButton.clipsToBounds = true
        self.callToActionView = callToActionButton
        
        // ТОЧНАЯ ВЕРСТКА из рабочего примера
        let leftStack = stack(headlineLabel, advertiserLabel, bodyLabel, callToActionButton).withMargins(.init(top: 8, left: 0, bottom: 8, right: 8))

        hstack(myMediaView, leftStack, spacing: 8)
        
        // AD Tag Label
        addSubview(adTag)
        adTag.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adTag.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            adTag.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            adTag.widthAnchor.constraint(greaterThanOrEqualToConstant: 25),
            adTag.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        adTag.backgroundColor = .systemFill
        adTag.layer.cornerRadius = 4
        adTag.clipsToBounds = true
        adTag.text = "AD"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - NativeAdBasicView (базовый стиль)

class NativeAdBasicView: NativeAdView {
    
    let adTag: UILabel = UILabel(text: "AD", font: .systemFont(ofSize: 10, weight: .semibold), textColor: .white)
    let headlineLabel = UILabel(text: "", font: .systemFont(ofSize: 17, weight: .medium), textColor: .label)
    let iconImageView = UIImageView()
    let bodyLabel = UILabel(text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: .secondaryLabel)
    let callToActionButton = UIButton(title: "", titleColor: .white, font: .boldSystemFont(ofSize: 18), backgroundColor: UIColor(hex: "#3871E0"), target: nil, action: nil)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        self.headlineView = headlineLabel
        self.iconView = iconImageView
        self.bodyView = bodyLabel
        self.callToActionView = callToActionButton
        
        adTag.withWidth(25)
        adTag.textAlignment = .center
        adTag.backgroundColor = UIColor(hex: "FFCC66")
        adTag.layer.cornerRadius = 2
        adTag.clipsToBounds = true
        adTag.text = "AD"
        
        iconImageView.layer.cornerRadius = 4
        iconImageView.clipsToBounds = true
        iconImageView.withWidth(40).withHeight(40)
        
        headlineLabel.numberOfLines = 2
        bodyLabel.numberOfLines = 2
        bodyLabel.textColor = .secondaryLabel
        
        callToActionButton.isUserInteractionEnabled = false
        callToActionButton.layer.cornerRadius = 8
        callToActionButton.clipsToBounds = true
        
        // Simple vertical layout
        let topStack = hstack(adTag, UIView()).withMargins(.init(top: 8, left: 10, bottom: 0, right: 10))
        let iconHeadlineStack = hstack(iconImageView, headlineLabel, spacing: 8).withMargins(.init(top: 8, left: 10, bottom: 0, right: 10))
        let bodyStack = bodyLabel//.withMargins(.init(top: 8, left: 10, bottom: 0, right: 10))
        let buttonStack = hstack(callToActionButton.withHeight(44)).withMargins(.init(top: 8, left: 10, bottom: 12, right: 10))
        
        stack(topStack, iconHeadlineStack, bodyStack, buttonStack, spacing: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NativeAdBasicView1: NativeAdView {

    let adTag: UILabel = UILabel(text: "AD", font: .systemFont(ofSize: 10, weight: .semibold), textColor: .white)
    let headlineLabel = UILabel(text: "", font: .systemFont(ofSize: 17, weight: .medium), textColor: .label)
    let iconImageView = UIImageView()
    let advLabel = UILabel(text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: .secondaryLabel)
    let storeLabel = UILabel(text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: .secondaryLabel)
    let callToActionButton = UIButton(title: "", titleColor: .white, font: .boldSystemFont(ofSize: 18), backgroundColor: UIColor(hex: "#3871E0"), target: nil, action: nil)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    func setupViews() {
        self.headlineView = headlineLabel
        self.iconView = iconImageView
        self.storeView = storeLabel
        self.advertiserView = advLabel
        self.callToActionView = callToActionButton

        adTag.withWidth(25)
        adTag.textAlignment = .center
        adTag.backgroundColor = UIColor(hex: "FFCC66")
        adTag.layer.cornerRadius = 2
        adTag.clipsToBounds = true
        adTag.text = "AD"

        iconImageView.layer.cornerRadius = 4
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFit
//        iconImageView.withHeight(40)

        headlineLabel.numberOfLines = 2
        storeLabel.numberOfLines = 2
        storeLabel.textColor = .secondaryLabel
        advLabel.numberOfLines = 2
        advLabel.textColor = .secondaryLabel

        callToActionButton.isUserInteractionEnabled = false
        callToActionButton.layer.cornerRadius = 8
        callToActionButton.clipsToBounds = true

        // Simple vertical layout
        let storeOrAdvStack = stack(storeLabel, advLabel)
        let infoSubStack = hstack(adTag, storeOrAdvStack, spacing: 5)
        let textStack = stack(headlineLabel, infoSubStack, spacing: 5)
        let infoStack = stack(textStack, callToActionButton, spacing: 10, distribution: .fillEqually)
        hstack(iconImageView, infoStack, spacing: 10).withMargins(.init(top: 8, left: 8, bottom: 8, right: 8))

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIColor Extension (из рабочего примера)

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        hexFormatted = hexFormatted.replacingOccurrences(of: "#", with: "")
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

//#Preview {
//    VStack {
//        NativeAdCardView()
//        NativeAdBannerView()
//        NativeAdCardView()
//    }
//}
