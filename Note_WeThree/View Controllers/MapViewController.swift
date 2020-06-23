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
        checkLocationServices()
    }
    
    func setupLocationManager()
    {
        mLocationManager.delegate = self
        mLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func addAnnotation()
    {
        mMapView.removeAnnotations(mMapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = mDestination!.coordinate
        CLGeocoder().reverseGeocodeLocation(self.mDestination!, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription )
                return
            }
            
            if placemarks?.count ?? 0 > 0 {
                let pm = placemarks![0]
                annotation.title = pm.thoroughfare ?? "nil" + ", " + pm.subThoroughfare!
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
    
    func centerViewOnUserLocation()
    {
        if let location = mLocationManager.location?.coordinate
        {
            let region = MKCoordinateRegion.init(center: location, span: SPAN)
            mMapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func centerLocation(_ sender: Any) {
        centerViewOnUserLocation()
    }
    
    func getDirections()
    {
        guard let location = mLocationManager.location?.coordinate else
        {
            showAlert(title: "Error", message: "The Application was not able to find your current location, please try again later.")
            return
        }
        if mDestination != nil
        {
            mMapView.removeOverlays(mMapView.overlays)
            let request = createDirectionRequest(from: location)
            let directions = MKDirections(request: request)
            
            directions.calculate { [unowned self] (response, error) in
                guard let response = response else
                {
                    self.showAlert(title: "Error", message: "Directions could not be calculated")
                    return
                }
                
                for route in response.routes
                {
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
    
    @IBAction func findWayButtonClicked(_ sender: Any) {
        getDirections()
    }
    
    func removeOverlaysAndAnnotations()
    {
        mMapView.removeOverlays(mMapView.overlays)
    }
    
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
    
    func showAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "okay", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension MapViewController: CLLocationManagerDelegate
{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension MapViewController: MKMapViewDelegate
{
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
