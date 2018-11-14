//
//  PhotoViewController.swift
//  Turista Virtual
//
//  Created by Wagner  Filho on 13/11/18.
//  Copyright © 2018 Artesmix. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var collecitonView: UICollectionView!
    @IBOutlet var newCollection: UIButton!
    
    var databaseController : DataBaseController!
    var pinRecieved : MKAnnotation!
    var nsfetchedResultsController: NSFetchedResultsController<Photo>!
    var pinSaved : Pin!
    var editMode: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialView()
        collecitonView.delegate = self
        collecitonView.dataSource = self
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        try? nsfetchedResultsController.performFetch()
    }
    
    // MARK: - Exe override func viewDidLoad
    func setupInitialView(){
        mapView.addAnnotation(pinRecieved)
        mapView.setRegion(MKCoordinateRegion(center: pinRecieved.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nsfetchedResultsController.fetchedObjects?.count != nil ? (nsfetchedResultsController.fetchedObjects?.count)! : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let prototypeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! CollectionViewCell
        prototypeCell.initWithPhoto(recievedPhotoInstance: (nsfetchedResultsController.fetchedObjects![indexPath.row]))
        return prototypeCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (navigationItem.rightBarButtonItem?.title == "Done"){
            let object = nsfetchedResultsController.object(at: indexPath)
            databaseController.viewContext.delete(object)
            try? databaseController.viewContext.save()
            collectionView.reloadData()
            try? nsfetchedResultsController.performFetch()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func newCollection(_ sender: Any) {
        if let results = nsfetchedResultsController.fetchedObjects{
            for objects in results{
                databaseController.viewContext.delete(objects)
                try? databaseController.viewContext.save()
            }
        }
        _ = Connection(coords: pinRecieved, databaseController: databaseController, pinToSave: pinSaved)
    }
    
}
