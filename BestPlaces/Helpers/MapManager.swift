import UIKit
import MapKit

class MapManager: UIViewController {
    
    //MARK: - properties
    lazy var locationManager = CLLocationManager()
    var directionsArray: [MKDirections] = []
    var placeCoordinate: CLLocationCoordinate2D?
    
    //MARK: - resetMapView

    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    // MARK: - setup placemarks

    func setupPlaceMarks(mapView: MKMapView, place: PlaceModel?) {
        guard let place = place else { return }
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { [self] placemarks, error in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            placeCoordinate = placemarkLocation.coordinate
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func checkLocationServices(mapView: MKMapView) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAutorization(mapView: mapView)
        } else {
                self.showAlert(title: "Location is not avaiable",
                          message: "Go to Settings >\nPrivacy >\nLocation >\n Location Services and turn on")
        }
    }
    
    func checkLocationAutorization(mapView: MKMapView) {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            break
        case .denied:
            self.showAlert(title: "Location is not avaiable",
                      message: "Go to Settings >\nBestPlaces >\nLocation")
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.showAlert(title: "Location is not avaiable",
                      message: "Go to Settings >\nBestPlaces >\nLocation")
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case in locationManager.authorizationStatus is available")
        }
    }
    
    //MARK: - get directions
    
    func getDirections(previousUserLocation: inout CLLocation?, mapView: MKMapView, infoRouteLabel: UILabel) {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousUserLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        
        directions.calculate { response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.showAlert(title: "Error", message: "Direction is not available")
                return
            }

            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = Int(route.expectedTravelTime).convertSeconds()
                
                infoRouteLabel.text = """
Distance: \(distance) km
Time: \(timeInterval.min):\(timeInterval.sec.setZeroForSeconds())
"""
                
                print("distance to the place: \(distance) km")
                print("time to the place: \(timeInterval.min):\(timeInterval.sec.setZeroForSeconds())")
            }
        }
    }
    
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    // MARK: - show alert for manager
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(ok)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
}

