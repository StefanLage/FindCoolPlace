//
//  PlacesViewController.swift
//  FindCoolPlaces
//
//  Created by Stefan Lage on 27/07/2017.
//  Copyright © 2017 Stefan Lage. All rights reserved.
//

import UIKit
import MapKit

class PlacesViewController: UIViewController {

    var viewModel: PlacesViewModel?

    // Location management
    let locationManager = CLLocationManager()
    var mapView: MKMapView!
    
    // Search places controller
    var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Bind the VM
        assert (self.viewModel != nil, "Kill it if we don't have any VM")
        guard self.viewModel != nil else {
            return
        }
        self.viewModel?.places.bindAndFire(listener: self.listener(places:))
        // Show the view below the navigation bar
        self.edgesForExtendedLayout = []
        self.configure()
        assert(self.mapView != nil, "the mapView should be set otherwise we can't go further")
        // Make sure the map is set
        guard self.mapView != nil else {
            return
        }
        self.configureConstraints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**

     Configure subviews and internal objects

     */
    private func configure()
    {
        // Init location manager
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()

        // Set up the map
        self.mapView = MKMapView()
        self.mapView!.showsUserLocation = true
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.mapView)

        // Define the searchbar
        self.searchController = UISearchController(searchResultsController: self)
        self.searchController.searchResultsUpdater = self
        let searchBar = self.searchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = self.searchController?.searchBar
        self.searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }
    
    /**

     Set up subviews contraints

     */
    private func configureConstraints()
    {
        // Define the size of the mapView -> match superview's frame
        let mapWidth = NSLayoutConstraint(item: self.mapView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0.0)
        let mapHeigth = NSLayoutConstraint(item: self.mapView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1, constant: 0.0)
        let mapTop = NSLayoutConstraint(item: self.mapView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0.0)
        let mapLeading = NSLayoutConstraint(item: self.mapView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0.0)

        self.view.addConstraints([mapTop, mapWidth, mapLeading, mapHeigth])
    }
}

// MARK: - Binding method to View model
private typealias PlacesViewControllerViewModel = PlacesViewController
extension PlacesViewControllerViewModel{
    
    func listener(places: [PlaceViewModel?]) -> (){
        print (places)
    }
}

// MARK: - Location manager delegate
private typealias PlacesViewControllerLocationDelegate = PlacesViewController
extension PlacesViewControllerLocationDelegate: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("error:: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    /**

     Useful to do anything with the map when user's location is updated for instance

     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            // Zoom on current location
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
}

// MARK: - Search places delegate
private typealias PlacesViewControllerSearchDelegate = PlacesViewController
extension PlacesViewControllerSearchDelegate: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        assert (viewModel != nil, "Kill it if we don't have any VM")
        guard viewModel != nil,
            let placeText = searchController.searchBar.text else {
            return
        }
        // Send location
        self.viewModel?.findPlaces(location: placeText)
    }
}
