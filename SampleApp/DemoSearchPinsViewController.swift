//
//  SearchPinsViewController.swift
//  ios-sdk
//
//  Created by Matt Smollinger on 1/6/17.
//  Copyright © 2017 Mapzen. All rights reserved.
//

import Pelias
import TangramMap
import CoreLocation

class DemoSearchPinsViewController: SampleMapViewController, UITextFieldDelegate, AutocompleteSearchDelegate {

  @IBOutlet weak var searchField: UITextField!

  @IBOutlet weak var displaySearch: UIButton!
  let searchListSegueId = "searchListSegueId"
  var firstTimeZoomToCurrentLocation = true
  var sceneDidLoad = false

  override func viewDidLoad() {
    super.viewDidLoad()

    try? loadStyleAsync(.bubbleWrap) { [unowned self] (style) in
      self.sceneDidLoad = true
      let _ = self.showCurrentLocation(true)
      self.showFindMeButon(true)
      if self.firstTimeZoomToCurrentLocation { self.shouldZoomToCurrentLocation() }
    }
    
    view.bringSubview(toFront: searchField)
    view.bringSubview(toFront: displaySearch)
    searchField.delegate = self
  }

  func shouldZoomToCurrentLocation() {
    if !sceneDidLoad { return }
    if lastSetPoint == nil { return }
    _ = resetCameraOnCurrentLocation()
    firstTimeZoomToCurrentLocation = false
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else {
      return
    }
    switch identifier {
    case searchListSegueId:
      if let searchVC = segue.destination as? DemoSearchListViewController {
        searchVC.delegate = self
      }
      break

    default:
      break
    }
  }

  func annotationClicked(annotation: PeliasMapkitAnnotation) {
    let coordinates = "lat: \(annotation.coordinate.latitude), lon:\(annotation.coordinate.longitude)"
    let alert = UIAlertController(title: annotation.title, message: coordinates, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }

  func selected(_ location: PeliasMapkitAnnotation) {
    print("Selected \(String(describing: location.title))")
    searchField.text = location.title
    location.setTarget(target: self, action: #selector(self.annotationClicked(annotation:)))
    try? self.removeAnnotations()
    try? self.add([location])

    animate(toZoomLevel: max(10, self.zoom), withDuration: 1.0)
    animate(toPosition: TGGeoPointMake(location.coordinate.longitude, location.coordinate.latitude), withDuration: 1.0)
  }

  override func locationDidUpdate(_ location: CLLocation) {
    super.locationDidUpdate(location)
    if (firstTimeZoomToCurrentLocation) {
      shouldZoomToCurrentLocation()
    }
  }
}
