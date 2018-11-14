//
//  MapViewController.swift
//  Turista Virtual
//
//  Created by Wagner  Filho on 13/11/18.
//  Copyright © 2018 Artesmix. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController,MKMapViewDelegate,NSFetchedResultsControllerDelegate {

    @IBOutlet var mapView: MKMapView!
    
    var databaseController : DataBaseController!
    var nsfetchedResultsController:NSFetchedResultsController<Pin>!
    var isEditingStatus : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //map view as delegate MKVDelegate
        mapView.delegate = self
        setMapRegion()
        longPressGesture()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpFetchedResults()
        fetchPin()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nsfetchedResultsController = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoCollection"{
            try? nsfetchedResultsController.performFetch()
            let destPhoto = segue.destination as? PhotoViewController
            let coords = sender as! MKAnnotation
            destPhoto?.pinRecieved = coords
            destPhoto?.databaseController = databaseController
            for pinToSend in nsfetchedResultsController.fetchedObjects!{
                if(pinToSend.latitude == coords.coordinate.latitude && pinToSend.longitude == coords.coordinate.longitude){
                    destPhoto?.pinSaved = pinToSend
                    break
                }
            }
        }
    }
    
    // MARK: - Exe override func viewDidLoad
    func setMapRegion(){
        var mapRegions = [MapRegion]()
        let nsfetchRequest:NSFetchRequest<MapRegion>=MapRegion.fetchRequest()
        do{
            mapRegions = try! databaseController.viewContext.fetch(nsfetchRequest)
        }
        if mapRegions.count > 0 {
            let newMapRegion = mapRegions.last
            let coordinate = CLLocationCoordinate2D(latitude: (newMapRegion?.centerlatitude)!, longitude: (newMapRegion?.centerlongitude)!)
            let span = MKCoordinateSpan(latitudeDelta: (newMapRegion?.spanlatitude)!, longitudeDelta: (newMapRegion?.spanlongitude)!)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
        
    }
    
    func SavePin(Coordinates : CLLocationCoordinate2D){
        let pinToAdd = Pin(context: databaseController.viewContext)
        pinToAdd.latitude = Coordinates.latitude
        pinToAdd.longitude = Coordinates.longitude
        do{
            try? databaseController.viewContext.save()
        }
        
    }
    
    @objc func addAnnotation(press : UILongPressGestureRecognizer){
        if press.state == .began{
            let locationForAnnotation = press.location(in: mapView)
            let coordinatesForAnnotation = mapView.convert(locationForAnnotation, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinatesForAnnotation
            mapView.addAnnotation(annotation)
            SavePin(Coordinates: coordinatesForAnnotation)
        }
    }
    
    func longPressGesture(){
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(press:)))
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
    }
    
   // MARK: - Exe override func viewWillAppear
    
    func setUpFetchedResults() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        nsfetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: databaseController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        nsfetchedResultsController.delegate = self
        try? nsfetchedResultsController.performFetch()
    }
    func fetchPin(){
        mapView.removeAnnotations(mapView.annotations)
        for objects in nsfetchedResultsController.fetchedObjects!{
            let annotationCoordinate = CLLocationCoordinate2D(latitude: objects.latitude, longitude: objects.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = annotationCoordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: - Exe override func prepare
    
    
    func DeletePin(_ viewToDelete: MKAnnotation?, _ mapView: MKMapView) {
        try? nsfetchedResultsController.performFetch()
        for pins in nsfetchedResultsController.fetchedObjects!{
            if (pins.latitude == viewToDelete?.coordinate.latitude && pins.longitude == viewToDelete?.coordinate.longitude){
                nsfetchedResultsController.managedObjectContext.delete(pins)
                mapView.removeAnnotation(viewToDelete!)
                break
            }
        }
        try? databaseController.viewContext.save()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if isEditingStatus{
            DeletePin(view.annotation, mapView)
        } else {
            performSegue(withIdentifier: "photoCollection", sender: view.annotation)
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }
    
    // MARK: - Map Padronized
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let entity = NSEntityDescription.entity(forEntityName: "MapRegion", in: databaseController.viewContext)
        let mapRegionToSave = MapRegion(entity: entity!, insertInto: databaseController.viewContext)
        
        mapRegionToSave.centerlatitude = mapView.region.center.latitude
        mapRegionToSave.centerlongitude = mapView.region.center.longitude
        mapRegionToSave.spanlatitude = mapView.region.span.latitudeDelta
        mapRegionToSave.spanlongitude = mapView.region.span.longitudeDelta
        
        try? databaseController.viewContext.save()
    }
    
    
    @IBAction func EditBtn(_ sender: Any) {
        isEditingStatus = !isEditingStatus
        if isEditingStatus{
            self.navigationItem.title = " Pressione para Deletar"
        } else {
            self.navigationItem.title = "Turista Virtual"
        }
    }
}

