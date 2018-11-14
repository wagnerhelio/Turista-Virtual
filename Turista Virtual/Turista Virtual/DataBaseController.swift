//
//  DataBaseController.swift
//  Turista Virtual
//
//  Created by Wagner  Filho on 13/11/18.
//  Copyright © 2018 Artesmix. All rights reserved.
//

import Foundation
import CoreData

class DataBaseController{
    let nspersistentContainer: NSPersistentContainer
   
    init(modelName : String) {
        nspersistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completition : (() -> Void)? = nil){
        nspersistentContainer.loadPersistentStores{ storeDescription,error in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            completition?()
        }
    }
    
    var viewContext : NSManagedObjectContext{
        return nspersistentContainer.viewContext
    }
}
