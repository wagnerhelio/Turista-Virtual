//
//  CollectionViewCell.swift
//  Turista Virtual
//
//  Created by Wagner  Filho on 14/11/18.
//  Copyright © 2018 Artesmix. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
  
    @IBOutlet var imageView: UIImageView!
    
    func initWithPhoto(recievedPhotoInstance : Photo){
        
        if recievedPhotoInstance.image == nil {
            let imageURL = URL(string: recievedPhotoInstance.imageURL!)
            URLSession.shared.dataTask(with: imageURL!){data,response,error in
                if error==nil{
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data! as Data)
                    }
                }
                
                }.resume()
        } else {
            imageView.image = UIImage(data: recievedPhotoInstance.image!)
        }
    }
}
