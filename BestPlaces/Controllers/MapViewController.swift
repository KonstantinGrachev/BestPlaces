import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    enum Constants {
        enum Constraints {
            static let sideIndentation: CGFloat = 30
            static let dismissButtonSize: CGFloat = 44
        }
    }
    
    //MARK: - properties
    var place: PlaceModel?
    lazy var locationManager = CLLocationManager()
    
    let annotationID = "annotationID"
    //MARK: - UI

    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    //MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        setNavigationController()
        setupPlaceMarks()
        setDelegates()
        checkLocationServices()
        setConstraints()
    }
    
    // MARK: - set navigation controller
    
    private func setNavigationController() {
        var image = UIImage(systemName: "xmark")
        image = image?.withTintColor(.black, renderingMode: .alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image,
                                                           style:.plain,
                                                           target: self,
                                                           action: #selector(dismissButtonTapped))
    }
    
    private func setDelegates() {
        mapView.delegate = self
        locationManager.delegate = self
    }
    
    @IBAction private func dismissButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - setup placemarks

    private func setupPlaceMarks() {
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
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // MARK: - set constraints

    private func setConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
            annotationView?.canShowCallout = true
        }
        if let imageData = place?.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.leftCalloutAccessoryView = imageView
        }
        return annotationView
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAutorization()
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAutorization()
        } else {
                self.showAlert(title: "Location is not avaiable",
                          message: "Go to Settings ->\nPrivacy ->\nLocation ->\n Location Services and turn on")
        }
    }
    
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAutorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            break
        case .denied:
            self.showAlert(title: "Location is not avaiable",
                      message: "Go to Settings ->\nBestPlaces ->\nLocation")
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.showAlert(title: "Location is not avaiable",
                      message: "Go to Settings ->\nBestPlaces ->\nLocation")
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case in locationManager.authorizationStatus is available")
        }
    }
}
