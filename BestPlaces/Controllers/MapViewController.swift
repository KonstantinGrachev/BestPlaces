import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate: AnyObject {
    func getAddress(address text: String)
}

class MapViewController: UIViewController {
    
    enum Constants {
        enum Constraints {
            static let sideIndentation: CGFloat = 40
            static let centerLocationButtonWidthHeight: CGFloat = 80
            static let addressLabelTopConstraint: CGFloat = 150
            static let pinWidthHeight: CGFloat = 40
        }
    }
    
    //MARK: - properties
    
    weak var delegate: MapViewControllerDelegate?
    
    var place: PlaceModel?
    lazy var locationManager = CLLocationManager()
    let annotationID = "annotationID"
    var placeCoordinate: CLLocationCoordinate2D?
    var isGetAddress = false {
        didSet {
            checkLocationServices()
            centerLocationButtonTapped()
            addressLabel.isHidden = false
            doneButton.isHidden = false
            pinImageView.isHidden = false
            goButton.isHidden = true
        }
    }
    
    //MARK: - UI

    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    private lazy var centerUserLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "compass"), for: .normal)
        button.backgroundColor = .gray
        button.clipsToBounds = true
        button.layer.cornerRadius = Constants.Constraints.centerLocationButtonWidthHeight / 2
        button.imageView?.contentMode = .scaleToFill
        button.addTarget(self, action: #selector(centerLocationButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 30)
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.setTitle("Done", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 30)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var goButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "direction"), for: .normal)
        button.addTarget(self, action: #selector(goButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let pinImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "pin")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let infoRouteLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()
    
    //MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setNavigationController()
        setDelegates()
        checkLocationServices()
        setupPlaceMarks()
        setConstraints()
    }
    
    // MARK: - setup views
    
    private func setNavigationController() {
        var image = UIImage(systemName: "xmark")
        image = image?.withTintColor(.black, renderingMode: .alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image,
                                                           style:.plain,
                                                           target: self,
                                                           action: #selector(dismissButtonTapped))
    }
    
    private func setupViews() {
        view.addSubview(mapView)
        mapView.addSubview(centerUserLocationButton)
        mapView.addSubview(addressLabel)
        mapView.addSubview(pinImageView)
        mapView.addSubview(doneButton)
        mapView.addSubview(goButton)
        mapView.addSubview(infoRouteLabel)
    }
    
    private func setDelegates() {
        mapView.delegate = self
        locationManager.delegate = self
    }
    
    // MARK: - @IBAction funcs

    @IBAction private func dismissButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func centerLocationButtonTapped() {
        guard let location = locationManager.location else { return }
        mapView.centerToLocation(location)
    }
    
    @IBAction private func doneButtonTapped() {
        guard let address = addressLabel.text else { return }
        delegate?.getAddress(address: address)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func goButtonTapped() {
        getDirection()
        infoRouteLabel.isHidden = false
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
            placeCoordinate = placemarkLocation.coordinate
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
        
        NSLayoutConstraint.activate([
            centerUserLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Constraints.sideIndentation),
            centerUserLocationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.Constraints.sideIndentation),
            centerUserLocationButton.widthAnchor.constraint(equalToConstant: Constants.Constraints.centerLocationButtonWidthHeight),
            centerUserLocationButton.heightAnchor.constraint(equalToConstant: Constants.Constraints.centerLocationButtonWidthHeight)
        ])
        
        NSLayoutConstraint.activate([
            addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Constraints.sideIndentation),
            addressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Constraints.sideIndentation),
            addressLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.Constraints.addressLabelTopConstraint)
        ])
        
        NSLayoutConstraint.activate([
            pinImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pinImageView.widthAnchor.constraint(equalToConstant: Constants.Constraints.pinWidthHeight),
            pinImageView.heightAnchor.constraint(equalToConstant: Constants.Constraints.pinWidthHeight)
        ])
        
        NSLayoutConstraint.activate([
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.Constraints.sideIndentation)
        ])
        
        NSLayoutConstraint.activate([
            goButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.Constraints.sideIndentation),
            goButton.widthAnchor.constraint(equalToConstant: Constants.Constraints.centerLocationButtonWidthHeight),
            goButton.heightAnchor.constraint(equalToConstant: Constants.Constraints.centerLocationButtonWidthHeight)
        ])
        
        NSLayoutConstraint.activate([
            infoRouteLabel.centerYAnchor.constraint(equalTo: goButton.centerYAnchor),
            infoRouteLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Constraints.sideIndentation),
            infoRouteLabel.trailingAnchor.constraint(equalTo: goButton.leadingAnchor, constant: -Constants.Constraints.sideIndentation)
        ])
    }
}

//MARK: - MKMapViewDelegate
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .cyan
        
        return renderer
    }
}

//MARK: - center user location

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

//MARK: - user location

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
                          message: "Go to Settings >\nPrivacy >\nLocation >\n Location Services and turn on")
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
}

extension MapViewController {
    private func getCenterLocationFromMapView(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = getCenterLocationFromMapView(for: mapView)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let cityName = placemark?.locality
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if cityName != nil && streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(cityName!), \(streetName!), \(buildNumber!)"
                } else if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
}

//MARK: - get direction

extension MapViewController {
    private func getDirection() {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        guard let request = createDirectionRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
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
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = Int(route.expectedTravelTime).convertSeconds()
                
                self.infoRouteLabel.text = """
                Distance: \(distance) km
                Time: \(timeInterval.min):\(timeInterval.sec.setZeroForSeconds())
"""
                
                print("distance to the place: \(distance) km")
                print("time to the place: \(timeInterval.min):\(timeInterval.sec.setZeroForSeconds())")
            }
        }
    }
    
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
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
}
