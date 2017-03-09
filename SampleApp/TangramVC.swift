//
//  TangramVC.swift
//  ios-sdk
//
//  Created by Matt Smollinger on 7/12/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import UIKit
import TangramMap
class TangramVC:  MapViewController, MapMarkerSelectDelegate {

  lazy var activityIndicator : UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
    indicator.color = .black
    indicator.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(indicator)

    let xConstraint = indicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
    let yConstraint = indicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
    NSLayoutConstraint.activate([xConstraint, yConstraint])

    return indicator
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupSwitchStyleBtn()
    markerSelectDelegate = self
    try? loadStyleAsync(.bubbleWrap) { [unowned self] (scene) in
      let _ = self.showCurrentLocation(true)
      self.showFindMeButon(true)
      self.showTestMarker()
    }
  }
  
  //MARK : MapSelectDelegate  
  func mapController(_ controller: MapViewController, didSelectMarker markerPickResult: TGMarkerPickResult, atScreenPosition position: CGPoint) {
    print("markerPicked")
    let alert = UIAlertController(title: "Marker Selected", message: nil, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }

  private func showTestMarker() {
    let markerId = markerAdd()
    let _ = markerSetStyling(markerId, styling: "{ style: 'points', color: 'white', size: [50px, 50px], collide: false, interactive: true }")
    let _ = markerSetPoint(markerId, coordinates: TGGeoPoint())
  }

  private func setupSwitchStyleBtn() {
    let btn = UIBarButtonItem.init(title: "Switch Map Style", style: .plain, target: self, action: #selector(openSettings))
    self.navigationItem.rightBarButtonItem = btn
  }

  @objc private func openSettings() {
    let actionSheet = UIAlertController.init(title: "Map Style", message: "Choose a map style", preferredStyle: .actionSheet)
    actionSheet.addAction(UIAlertAction.init(title: "Bubble Wrap", style: .default, handler: { [unowned self] (action) in
      self.indicateLoadStyle(style: .bubbleWrap)
    }))
    actionSheet.addAction(UIAlertAction.init(title: "Cinnabar", style: .default, handler: { [unowned self] (action) in
      self.indicateLoadStyle(style: .cinnabar)
    }))
    actionSheet.addAction(UIAlertAction.init(title: "Refill", style: .default, handler: { [unowned self] (action) in
      self.indicateLoadStyle(style: .refill)
    }))
    actionSheet.addAction(UIAlertAction.init(title: "Walkabout", style: .default, handler: { [unowned self] (action) in
      self.indicateLoadStyle(style: .walkabout)
    }))
    actionSheet.addAction(UIAlertAction.init(title: "Zinc", style: .default, handler: { [unowned self] (action) in
      self.indicateLoadStyle(style: .zinc)
    }))
    actionSheet.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { [unowned self] (action) in
      self.dismiss(animated: true, completion: nil)
    }))
    self.navigationController?.present(actionSheet, animated: true, completion: nil)
  }

  private func indicateLoadStyle(style: MapStyle) {
    activityIndicator.startAnimating()
    try? loadStyleAsync(style, onStyleLoaded: { [unowned self] (style) in
      self.activityIndicator.stopAnimating()
    })
  }
}