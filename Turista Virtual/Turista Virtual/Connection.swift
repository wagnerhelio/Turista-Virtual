//
//  Connection.swift
//  Turista Virtual
//
//  Created by Wagner  Filho on 13/11/18.
//  Copyright © 2018 Artesmix. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class Connection: NSFetchedResultsController<Photo> {
    
    var nsfetchedResultsController:NSFetchedResultsController<Photo>!
    var dbController : DataBaseController!
    
    init(coords : MKAnnotation,databaseController : DataBaseController,pinToSave : Pin){
        super.init()
        
        dbController = databaseController
        
        self.getNetworkRequest(pinRecieved: coords, pinToSave: pinToSave)
        
        try? self.dbController.viewContext.save()
    
        self.setupFetchRequest(databaseController,pintoSave: pinToSave)
    }
    
    
    
    func FlickrURL(parameters : [String : AnyObject]) -> URL{
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.Flickr.APIScheme
        urlComponents.host = Constants.Flickr.APIHost
        urlComponents.path = Constants.Flickr.APIPath
        urlComponents.queryItems = [URLQueryItem]()
        
        for(key,value) in parameters{
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            urlComponents.queryItems?.append(queryItem)
        }
        return urlComponents.url!
    }
    
    
    func getNetworkRequest(pinRecieved : MKAnnotation,pinToSave : Pin){
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: getbbox(pinRecieved: pinRecieved),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        networkSessio(methodParameters, coords: pinRecieved, pinToSave: pinToSave)
    }
    
    func networkSessio(_ methodParameters: [String : String],coords : MKAnnotation,pinToSave : Pin) {
        let session = URLSession.shared
        let request = URLRequest(url: FlickrURL(parameters: methodParameters as [String : AnyObject]))
        let task = session.dataTask(with: request) {
            (data,request,error) in
            if (error == nil){
                let parsedResult : [String : AnyObject]!
                do{
                    try parsedResult = JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : AnyObject]
                    let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject]
                    let photoArray = photosDictionary![Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]]
                    for _ in 0...10{
                        let randomNo = Int(arc4random_uniform(UInt32((photoArray?.count)!-2)))
                        let randomPhotoArray = photoArray![randomNo] as? [String:AnyObject]
                        let imageURLString = randomPhotoArray![Constants.FlickrResponseKeys.MediumURL] as! String
                        self.SavePin(photoURLToSave: imageURLString, pinToSave: pinToSave)
                    }
                    
                } catch {
                    print("Error in Fetching Results")
                }
                
            }//Check For Error Ends Here
        }//Data Request Ends Here
        task.resume()
        
    }
    
    func getbbox(pinRecieved : MKAnnotation) -> String{
        
        let minimumLon = max(pinRecieved.coordinate.longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(pinRecieved.coordinate.latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(pinRecieved.coordinate.longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(pinRecieved.coordinate.latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    func setupFetchRequest(_ databaseController: DataBaseController,pintoSave : Pin) {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin==%@", argumentArray: [pintoSave])
        nsfetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: databaseController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do{
            try nsfetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func SavePin(photoURLToSave : String,pinToSave : Pin){
        let photoToSave = Photo(context: dbController.viewContext)
        photoToSave.imageURL = photoURLToSave
        photoToSave.pin = pinToSave
        let photoURL = URL(string: photoURLToSave)
        URLSession.shared.dataTask(with: photoURL!){ (data,response,error) in
            if error == nil{
                DispatchQueue.global().async {
                    photoToSave.image = data
                }
            }
            }.resume()
        try? dbController.viewContext.save()
    }
    
    
}
