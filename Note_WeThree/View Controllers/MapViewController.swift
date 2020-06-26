//
//  MapViewController.swift
//  Note_WeThree
//
//  Created by Chetan on 2020-06-22.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mMapView: MKMapView!
    let mLocationManager = CLLocationManager()
    let SPAN = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    var mTransportType: MKDirectionsTransportType = .automobile
    @IBOutlet weak var mSegmentedControl: UISegmentedControl!
    @IBOutlet weak var mBackButton: UIButton!
    
    // To Set the value of the location of the note
    var mDestination: CLLocation?
    {
        didSet
        {
            if mDestination != nil
            {
                self.addAnnotation()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        checkLocationServices()
    }
    
    /// Setting the Style for the back button, while hiding navigation bar and having floating back button
    func setupBackButton()
    {
        let image = UIImage(named: "back")?.withRenderingMode(.alwaysTemplate)
        mBackButton.setImage(image, for: .normal)
        mBackButton.tintColor = UIColor.systemBlue
    }
    
    /// Sets up the Location Manager
    func setupLocationManager()
    {
        mLocationManager.delegate = self
        mLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// Add the Notes Location as Annotation
    private func addAnnotation()
    {
//        mMapView.removeAnnotations(mMapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = mDestination!.coordinate
        CLGeocoder().reverseGeocodeLocation(self.mDestination!, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription )
                return
            }
            
            if placemarks?.count ?? 0 > 0 {
                let pm = placemarks![0]
                annotation.title = self.getTitle(placemark: pm)
                annotation.subtitle = pm.subLocality
                self.mMapView.addAnnotation(annotation)
                print(pm)
            }
            else
            {
                annotation.title = "Unknown Place"
                self.mMapView.addAnnotation(annotation)
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func getTitle(placemark: CLPlacemark) -> String
    {
        var title: String = ""
        if let stf = placemark.subThoroughfare
        {
            title.append(stf)
        }
        if let tf = placemark.thoroughfare
        {
            if title != ""
            {
                title.append(", ")
            }
            title.append(tf)
        }
        if title == ""
        {
            return "Note Creation Location"
        }
        return title
    }
    
    /// Checks if the Location Services is enabled or not
    func checkLocationServices()
    {
        if CLLocationManager.locationServicesEnabled()
        {
            setupLocationManager()
            checkLocationAuthorization()
        }
        else
        {
            showAlert(title: "Location Services are Disabled", message: "The application required Location Services to be enabled to show your location and directions. Please enable Location Services from settings")
        }
    }
    
    /// Checks Location Authorization / Permissions Status
    func checkLocationAuthorization()
    {
        switch CLLocationManager.authorizationStatus()
        {
        case .authorizedWhenInUse:
            mMapView.showsUserLocation = true
            centerViewOnUserLocation()
            mLocationManager.startUpdatingLocation()
            break
        case .denied:
            showAlert(title: "Location Permissions Denied!", message: "The application required Location Permissions to be enabled to show your location and directions. Please Allow Location Permissions from settings")
        case .notDetermined:
            mLocationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Code Add alert
            break
        case .authorizedAlways:
            break
        @unknown default:
            // Code
            break
        }
    }
    
    /// Centers the View on User Location
    func centerViewOnUserLocation()
    {
        if let location = mLocationManager.location?.coordinate
        {
            let region = MKCoordinateRegion.init(center: location, span: SPAN)
            mMapView.setRegion(region, animated: true)
        }
    }
    
    /// Action Function for the Center Location to user Button
    /// - Parameter sender: Center Location to user Button
    @IBAction func centerLocation(_ sender: Any) {
        centerViewOnUserLocation()
    }
    
    /// Function to display directions on the MapView
    func getDirections()
    {
        print("1")
        guard let location = mLocationManager.location?.coordinate else
        {
            showAlert(title: "Error", message: "The Application was not able to find your current location, please try again later.")
            return
        }
        print(2)
        if mDestination != nil
        {
            mMapView.removeOverlays(mMapView.overlays)
            let request = createDirectionRequest(from: location)
            let directions = MKDirections(request: request)
            print(3)
            directions.calculate { [unowned self] (response, error) in
                guard let response = response else
                {
                    self.showAlert(title: "Error", message: "Directions could not be calculated")
                    return
                }
                print(4)
                for route in response.routes
                {
                    print(5)
                    self.mMapView.addOverlay(route.polyline)
                    self.mMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
            }
        }
        else
        {
            showAlert(title: "Destination Not Selected", message: "Please select a destination before trying to find a way.")
        }
    }
    
    /// Function to create a Direction Request
    /// - Parameter coordinate: Origin Coordinates
    /// - Returns: Direction Request Object
    func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request
    {
        let destination_coordinate = mDestination!.coordinate
        let starting_location = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destination_coordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: starting_location)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = self.mTransportType
        request.requestsAlternateRoutes = false
        return request
    }
    
    /// Action Function for Find Way Button
    /// - Parameter sender: Find Way Button
    @IBAction func findWayButtonClicked(_ sender: Any) {
        getDirections()
    }
    
    /// Removes previous Directions displayed on MapView
    func removeOverlaysAndAnnotations()
    {
        mMapView.removeOverlays(mMapView.overlays)
    }
    
    /// Value changed Function for Segmented Control ( Automobile / Walking)
    /// - Parameter sender: Segmented Control ( Automobile / Walking)
    @IBAction func transportationTypeChanged(_ sender: Any) {
        switch mSegmentedControl.selectedSegmentIndex {
        case 0:
            mTransportType = .automobile
        case 1:
            mTransportType = .walking
        default:
            break
        }
    }
    
    /// Generalised Function to show Alerts
    /// - Parameters:
    ///   - title: Title of Alert
    ///   - message: Message in Alert
    func showAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "okay", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Function to hide Navigation Bar
    /// - Parameter animated: if view appearance will be animated or not
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    /// Function to show Navigation Bar
    /// - Parameter animated: if view disappearance will be animated or not
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /// Action Function for Back Button. Pop's this View from stack
    /// - Parameter sender: Back Button
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MapViewController: CLLocationManagerDelegate
{
    
    /// In-built function called when Location Authorization / Permission Changed
    /// - Parameters:
    ///   - manager: CLLocation Manager
    ///   - status: Status of Authorization / Permission
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension MapViewController: MKMapViewDelegate
{
    /// In-built function called when a overlay has to be displayed. Using it to display different color lines when automobile or walking is used
    /// - Parameters:
    ///   - mapView: MapView on which overlay is being drawn
    ///   - overlay: Overlay that is being drawn
    /// - Returns: Overlay Rendered Object which will render the Overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        if(mTransportType == .automobile)
        {
            renderer.strokeColor = .blue
        }
        else if(mTransportType == .walking)
        {
            renderer.strokeColor = .green
        }
        return renderer
    }
}
