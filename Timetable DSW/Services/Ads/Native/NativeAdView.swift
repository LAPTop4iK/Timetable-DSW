//
//  NativeAdView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 21/10/2025.
//


// ===== FILE: Services/Ads/Native/NativeAdView.swift =====

import GoogleMobileAds
import SwiftUI

struct NativeAdViewRepresentable: UIViewRepresentable {
    public typealias UIViewType = NativeAdView
    
    @ObservedObject var nativeViewModel: NativeAdViewModel
    var style: NativeAdViewStyle
    
    init(nativeViewModel: NativeAdViewModel, style: NativeAdViewStyle = .card) {
        self.nativeViewModel = nativeViewModel
        self.style = style
    }
    
    public func makeUIView(context: Context) -> NativeAdView {
        return style.view
    }
    
    func removeCurrentSizeConstraints(from mediaView: UIView) {
        mediaView.constraints.forEach { constraint in
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                mediaView.removeConstraint(constraint)
            }
        }
    }
    
    public func updateUIView(_ nativeAdView: NativeAdView, context: Context) {
        guard let nativeAd = nativeViewModel.nativeAd else { return }
        
        // Media View
        if let mediaView = nativeAdView.mediaView {
            mediaView.contentMode = .scaleAspectFill
            mediaView.clipsToBounds = true

            let aspectRatio = nativeAd.mediaContent.aspectRatio

            debugPrint("Google aspectRatio: \(aspectRatio), hasVideoContent: \(nativeAd.mediaContent.hasVideoContent)")
            
            if style == .largeBanner {
                removeCurrentSizeConstraints(from: mediaView)
                if aspectRatio > 0 {
                    if aspectRatio > 1 {
                        mediaView.widthAnchor.constraint(equalTo: mediaView.heightAnchor, multiplier: aspectRatio).isActive = true
                    } else {
                        mediaView.widthAnchor.constraint(equalTo: mediaView.heightAnchor, multiplier: 1).isActive = true
                    }
                } else {
                    mediaView.widthAnchor.constraint(equalTo: mediaView.heightAnchor, multiplier: 16/9).isActive = true
                }
            }
            nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        }


        // headline require
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        
        // body
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        // icon
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = (nativeAd.icon == nil)
        
        // ratting
        let starRattingImage = imageOfStars(from: nativeAd.starRating)
        (nativeAdView.starRatingView as? UIImageView)?.image = starRattingImage
        nativeAdView.starRatingView?.isHidden = (starRattingImage == nil)
        
        // store
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil
        
        // price
        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil
        
        // advertiser
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = (nativeAd.advertiser == nil)
        
        // button
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        if style == .largeBanner, let body = nativeAd.body, body.count > 0 {
            nativeAdView.callToActionView?.isHidden = true
        }
        
        // КРИТИЧНО: Связываем view с ad ПОСЛЕДНИМ
        nativeAdView.nativeAd = nativeAd
    }

//    func updateUIView(_ nativeAdView: NativeAdView, context: Context) {
//      guard let nativeAd = nativeViewModel.nativeAd else { return }
//
//      // Each UI property is configurable using your native ad.
//      (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
//
//      nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
//
//      (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
//
//      (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
//
//      (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
//
//      (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
//
//      (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
//
//      (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
//
//      (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
//
//      // For the SDK to process touch events properly, user interaction should be disabled.
//      nativeAdView.callToActionView?.isUserInteractionEnabled = false
//
//      // Associate the native ad view with the native ad object. This is required to make the ad
//      // clickable.
//      // Note: this should always be done after populating the ad views.
//      nativeAdView.nativeAd = nativeAd
//    }

    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }
        
        // Используйте Bundle.main для ваших assets или создайте изображения
        // Для тестирования можно использовать SF Symbols
        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        }
        
        return nil
    }
}
