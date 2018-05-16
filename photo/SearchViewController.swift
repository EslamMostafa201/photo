//
//  ViewController.swift
//  photo
//
//  Created by Admin on 5/14/18.
//  Copyright © 2018 Eslam. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SDWebImage

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    let api_key = "35a3f08f70424e9c6a5624ba62449cc3"
    
    
    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var photoTitles : [String] = [String]()
    var usersID : [String] = [String]()
    var photosID : [String] = [String]()
    var imageUrls : [String] = [String]()
    
    //url of photo source
    var photoURL : String = ""
    var textTapped : String = ""
    //url we make by it request for (flickr.photos.search)
    var photo_url  :String = ""
    var photo_id : String = ""
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CustomCellTableViewCell", bundle: nil) , forCellReuseIdentifier: "Custom")
        searchText.delegate = self
        searchText.returnKeyType = UIReturnKeyType.done
        searchText.placeholder = "Search what you want here !"
        getPhotos(url: photo_url)
    
    }
 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///MARK: - search bar Delegate Methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if self.searchText.text == nil || self.searchText.text == ""{
            view.endEditing(true)
            self.tableView.reloadData()
        }
        else{
            textTapped = self.searchText.text!
            photo_url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=35a3f08f70424e9c6a5624ba62449cc3&text=\(textTapped)&per_page=10&format=json&nojsoncallback=1"

            photoTitles.removeAll(keepingCapacity: false)
            usersID.removeAll(keepingCapacity: false)
            photosID.removeAll(keepingCapacity: false)
            imageUrls.removeAll(keepingCapacity: false)

            getPhotos(url: photo_url)
            searchText.endEditing(true)
            self.tableView.reloadData()
            
        }
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let photoV = storyBoard.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        photoV.userID = usersID[indexPath.row]
        self.navigationController?.pushViewController(photoV, animated: true)
        
    }
    
    //make request to get searched photos or Return a list of photos matching some criteria from (flickr.photos.search) by (text)
    
    func getPhotos(url : String){
        Alamofire.request(url).responseJSON{
            response in
            if response.result.isSuccess{
               
                let photoJSON : JSON = JSON(response.result.value!)
                
                var photoID = ""
                var userID = ""
                var photoTitle = ""
                for i in 0..<10{
                    photoID = photoJSON["photos"]["photo"][i]["id"].stringValue
                    userID = photoJSON["photos"]["photo"][i]["owner"].stringValue
                    photoTitle = photoJSON["photos"]["photo"][i]["title"].stringValue
                    self.photosID.append(photoID)
                    self.usersID.append(userID)
                    self.photoTitles.append(photoTitle)
                    self.getPhotoData(photoID)
                   // self.getUserPhotos(userID)
                }

            }
            else{
                print("Error \(String(describing : response.result.error))")
            }
            
            
        }
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

}

