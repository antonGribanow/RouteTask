//
//  ViewController.swift
//  RouteTask
//
//  Created by Anton Gribanow on 07/02/2022.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    let mapView : MKMapView = { // инициализируем карту
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    let addAdressButton : UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "AddAdress"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
  
    let routeButton : UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "Route"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
        
    }()
    
    let resetButton : UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "Reset"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
        
    }()
    
    var annotationArray = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        setConstraints()
        
        addAdressButton.addTarget(self, action: #selector(addAdressButtonTapped), for: .touchUpInside)  //создаем таргет
        routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)  //создаем таргет
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)  //создаем таргет
    
    }
    
    @objc func addAdressButtonTapped() {
        alertAddAdress(title: "Add", placeholder: "Write Adress") { [self] (text) in
            setupPlacemark(adressPlase: text)
        }
    }
    
    @objc func routeButtonTapped() {
        
        for index in 0...annotationArray.count-2 {
            createDirectionRequest(startCoordinate: annotationArray[index].coordinate, destinationCoordinate: annotationArray[index+1].coordinate)
        }
        
        mapView.showAnnotations(annotationArray, animated: true)
    }
    
    @objc func resetButtonTapped() {

        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotation(mapView.annotations) // problem
        annotationArray = [MKPointAnnotation]()
        routeButton.isHidden = true
        resetButton.isHidden = true
    }
    
    private func setupPlacemark(adressPlase: String) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adressPlase) { [self] (placemarks, error) in
            
            if let error = error{
                print(error)
                alertError(title: "Error", message: "Server is unavalibe")
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(adressPlase)"
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            annotationArray.append(annotation)
            
            if annotationArray.count > 2 {
                routeButton.isHidden = false
                resetButton.isHidden = false
            }
            
            mapView.showAnnotations(annotationArray, animated: true)
        }
    }


private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
    
    let startLocation = MKPlacemark(coordinate: startCoordinate)
    let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
    
    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: startLocation)
    request.destination = MKMapItem(placemark: destinationLocation)
    request.transportType = .walking
    request.requestsAlternateRoutes = true
    
    let diraction = MKDirections(request: request)
    diraction.calculate { (responce, error) in
        
        if let error = error {
            print(error)
            return
        }
        
        guard let responce = responce else {
            self.alertError(title: "Error", message: "Diraction is unavalible")
            return
            }
        
        var minRoute = responce.routes[0]
        for route in responce.routes{
            minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
        self.mapView.addOverlay(minRoute.polyline)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer  = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}


extension ViewController {
    
    func setConstraints() { //установка констреинтов
        
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        mapView.addSubview(addAdressButton)
        NSLayoutConstraint.activate([
            addAdressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addAdressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            addAdressButton.heightAnchor.constraint(equalToConstant: 70),
            addAdressButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        mapView.addSubview(routeButton)
        NSLayoutConstraint.activate([
            routeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            routeButton.heightAnchor.constraint(equalToConstant: 50),
            routeButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            resetButton.heightAnchor.constraint(equalToConstant: 50),
            resetButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
}



 
