//
//  PhotosViewController.swift
//  photo
//
//  Created by Admin on 5/14/18.
//  Copyright © 2018 Eslam. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SDWebImage

class PhotosViewController :UIViewController,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!

    var photoTitles : [String] = [String]()
    var userID : String = ""
    var photosID : [String] = [String]()
    var imageUrls : [String] = [String]()
    var photoURL : String = ""
    
  
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        getUserPhotosURL(userID)
        tableView.register(UINib(nibName: "CustomCellTableViewCell", bundle: nil) , forCellReuseIdentifier: "Custom")
        
    }
    
    
  
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Custom", for: indexPath) as! CustomCellTableViewCell
        
        cell.avatarImage.sd_setImage(with: URL(string : imageUrls[indexPath.row]))
        
        cell.photoTitle.text! = photoTitles[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    
   //make requset to get photo url from (flickr.photos.getSizes) to fetch it
    
    func getPhotoSizes(url : String){
        Alamofire.request(url).responseJSON{
            response in
            if response.result.isSuccess{

                let photoJSON : JSON = JSON(response.result.value!)
                self.photoURL = photoJSON["sizes"]["size"][0]["source"].stringValue
     
                self.imageUrls.append(self.photoURL)
                self.tableView.reloadData()
                
            }
            else{
                print("Error \(String(describing : response.result.error))")
            }
        }
    }
    
    
    //make  url to get photo by id to previous func (getPhotoSizes)
    
    func getPhotoData(_ photoId : String){
        var id_url : String
        id_url = "https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=35a3f08f70424e9c6a5624ba62449cc3&photo_id=\(photoId)&format=json&nojsoncallback=1"
        
        getPhotoSizes(url: id_url)
    }
    
    //Return photos from the given user's photostream
    //make request to API to get photosID, photoTitle  by userID from(flickr.people.getPhotos)
    
    func getUserPhotos(url : String){
        Alamofire.request(url).responseJSON{
            response in
            if response.result.isSuccess{
   
                let photoJSON : JSON = JSON(response.result.value!)
                var photoID = ""
                var photoTitle = ""
                for i in 0..<10{
                    photoID = photoJSON["photos"]["photo"][i]["id"].stringValue
                    photoTitle = photoJSON["photos"]["photo"][i]["title"].stringValue
                    
                    self.photosID.append(photoID)
                    self.photoTitles.append(photoTitle)
                    self.getPhotoData(photoID)
                }
             

            }
            else{
                print("Error \(String(describing : response.result.error))")
            }
            
            
        }
    }
    
    //make  url of  all user photos to previous func (getUserPhotos)
    func getUserPhotosURL(_ userId : String){
        var userid_url : String
        userid_url = "https://api.flickr.com/services/rest/?method=flickr.people.getPhotos&api_key=35a3f08f70424e9c6a5624ba62449cc3&user_id=\(userId)&format=json&nojsoncallback=1"

        getUserPhotos(url: userid_url)
    }
}
