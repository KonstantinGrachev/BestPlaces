import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate: AnyObject {
    func getAddress(text string: String)
}

class MapViewController: UIViewController {
    
    enum Constants {
        enum Constraints {
            static let sideIndentation: CGFloat = 40
            static let centerLocationButtonWidthHeight: CGFloat = 50
            static let addressLabelTopConstraint: CGFloat = 150
            static let pinWidthHeight: CGFloat = 40
        }
    }
    
    //MARK: - properties
    
    weak var delegate: MapViewControllerDelegate?
    
    var place: PlaceModel?
    lazy var locationManager = CLLocationManager()
    let annotationID = "annotationID"
    var isGetAddress = false {
        didSet {
            checkLocationServices()
            centerLocationButtonTapped()
            addressLabel.isHidden = false
            doneButton.isHidden = false
            pinImageView.isHidden = false
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
    
    private let pinImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "pin")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
    
    @IBAction private func doneButtonTapped() {
        print("doneButton")
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
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
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
