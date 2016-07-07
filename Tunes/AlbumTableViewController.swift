//
//  AlbumTableViewController.swift
//  Tunes
//
//  Created by Erica Correa on 5/26/16.
//  Copyright © 2016 Turn to Tech. All rights reserved.
//

import UIKit

class AlbumTableViewController: UITableViewController, UISearchBarDelegate {
    
    //initialized empty array
    var searchResults = [Album]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let cellNib = UINib.init(nibName: "AlbumTableViewCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: "AlbumCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - UISearchBar delegate method
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        guard let query = searchBar.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            else { return }
        
        guard let url = NSURL(string: "https://itunes.apple.com/search?term=\(query)&media=music&entity=album")
            else { return }
        
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            guard let myData:NSData = data where error == nil
                else { return }
            
            let decodedJson:AnyObject
            
            do {
                decodedJson = try NSJSONSerialization.JSONObjectWithData(myData, options: [])
            } catch _ { return }
            
            let albums = decodedJson["results"]! as! [Dictionary<String,AnyObject>]
            
            self.searchResults.removeAll()
            for album in albums {
                
                let name = album["collectionName"]! as! String
                let artist = album["artistName"]! as! String
                guard let price:Double = album["collectionPrice"] as? Double
                    else { continue }
                let url:NSURL? = NSURL(string: album["collectionViewUrl"]! as! String)!
                
                let newAlbum = Album(name:name, artist:artist, price:price)
                if url != nil {
                    newAlbum.url = url
                }
                self.searchResults.append(newAlbum)
                
                guard let albumUrl:NSURL = NSURL(string: album["artworkUrl60"]! as! String)
                    else { return }
                
                self.getImage(forAlbum: newAlbum, withURL: albumUrl)
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        
        task.resume()
    }
    
    func getImage(forAlbum album:Album, withURL url:NSURL) {
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                guard let myData:NSData = data, let _:NSURLResponse = response where error == nil
                    else { return }
                
                guard let image = UIImage(data:myData)
                    else { return }
                
                album.image = image
                self.tableView.reloadData()
            })
        }
        task.resume()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AlbumCell", forIndexPath: indexPath) as! AlbumTableViewCell

        let album:Album = self.searchResults[indexPath.row]
        cell.albumTitleLabel.text = album.name
        cell.albumPriceLabel.text = String(format: "$%.2f", album.price)
        cell.albumArtistLabel.text = album.artist
        cell.albumCoverImage.image = album.image

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let albumUrl = self.searchResults[indexPath.row].url
            else { return }
        
        UIApplication.sharedApplication().openURL(albumUrl)
    }
    
    
    
    
    
    
    
}
