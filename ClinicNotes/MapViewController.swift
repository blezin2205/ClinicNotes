//
//  MapViewController.swift
//  ClinicNotes
//
//  Created by Blezin on 08.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import Foundation
import GoogleMaps
import CoreLocation
import GooglePlaces
import Alamofire
import SwiftyJSON
import Firebase


protocol MapViewControllerDelegate {
    func getAddress(_ address: String?, _ city: String?, _ longitude: String?, _ latitude: String?)
}

class GooglemapVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
    
    var clinic: FIRClinic?
    var clinicLocation: String?
    var clinicName: String?
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var currentCity = String()
    var viewForSearch: UIView?
    var endCoord: CLLocation?
    
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    
    lazy var closeButton: UIButton = {
        
        let icon = UIImage(named: "camcel")!
        let closeButton = UIButton()
        closeButton.setImage(icon, for: .normal)
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return closeButton
    }()
    
    lazy var addressLabel: UILabel = {
        
        let addressLabel = UILabel()
        addressLabel.textAlignment = .center
        addressLabel.text = ""
        addressLabel.textColor = .black
        addressLabel.font = .boldSystemFont(ofSize: 21)
        addressLabel.lineBreakMode = .byWordWrapping
        addressLabel.numberOfLines = 2
        return addressLabel
        
    }()
    
    lazy var getButton: UIButton = {
        
        let getButton = UIButton()
        getButton.setTitle("Done", for: .normal)
        getButton.setTitleColor(.black, for: .normal)
        getButton.titleLabel?.font = .boldSystemFont(ofSize: 21)
        getButton.addTarget(self, action: #selector(getAddress), for: .touchUpInside)
        return getButton
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        mapView.settings.compassButton = true
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.tableCellBackgroundColor = .darkGray
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        viewForSearch = UIView(frame: CGRect(x: 0,
                                       y: 19,
                                       width: (searchController?.searchBar.frame.width)!,
                                       height: (searchController?.searchBar.frame.height)!))
        
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
    }
    
    @objc func handleTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func getAddress(_ sender: UIButton) {
        mapViewControllerDelegate?.getAddress(addressLabel.text,
                                              currentCity,
                                              endCoord?.coordinate.longitude.description,
                                              endCoord?.coordinate.latitude.description)
        clinic?.ref?.updateChildValues(["longitude": endCoord?.coordinate.longitude.description ?? "",
                                        "latitude": endCoord?.coordinate.latitude.description ?? ""])
        dismiss(animated: true, completion: nil)
        
    }
    
    
    private func setupView() {
        
        viewForSearch!.addSubview((searchController?.searchBar)!)
        view.addSubview(viewForSearch!)
        self.view.addSubview(closeButton)
        self.view.addSubview(addressLabel)
        self.view.addSubview(getButton)
        getButton.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil,
                         padding: .init(top: 0, left: 0, bottom: 10, right: 0),
                         size: .init(width: 80, height: 50))
        getButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        closeButton.anchor(top: viewForSearch?.bottomAnchor, leading: nil, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor,
                           padding: .init(top: 12, left: 0, bottom: 0, right: 12),
                           size: .init(width: 30, height: 30))
        addressLabel.anchor(top: closeButton.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor,
                            padding: .init(top: 6, left: 12, bottom: 0, right: 12),
                            size: .init(width: view.frame.width, height: 60))
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations.last
        let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude, zoom: 15)
        mapView.camera = camera
        
        locationManager.stopUpdatingLocation()
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.firstResult()
            let streetName = placemark?.thoroughfare
            self.currentCity = placemark?.locality ?? ""
            self.endCoord = CLLocation(latitude: placemark!.coordinate.latitude, longitude: placemark!.coordinate.longitude)
            
            if streetName != nil {
                self.addressLabel.text = "\(streetName!)"
            }
        }
    }
    
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        mapView.clear()
        let marker = GMSMarker(position: coordinate)
        let coordinates = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        marker.position = coordinates
        marker.map = mapView
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinates) { (response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let response = response else {return}
            
            self.addressLabel.text = response.firstResult()?.thoroughfare
            self.currentCity = response.firstResult()?.locality ?? ""
            self.endCoord = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("3")
    }
    
}


extension GooglemapVC: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        
        searchController?.isActive = false
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 16.0)
        let marker = GMSMarker()
        endCoord = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        marker.map = mapView
        mapView.camera = camera
        addressLabel.text = place.formattedAddress
        currentCity = place.formattedAddress ?? ""
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        print("Error: ", error.localizedDescription)
    }
    
}


