//
//  Album.swift
//  Tunes
//
//  Created by Erica Correa on 5/26/16.
//  Copyright © 2016 Turn to Tech. All rights reserved.
//

import UIKit

class Album: NSObject {
    
    var name: String
    var artist: String
    var price: Double
    var url: NSURL?
    
    var image: UIImage = UIImage(named: "generic_album")!
    
    init(name:String, artist:String, price:Double){
        self.name = name
        self.artist = artist
        self.price = price
    }
    
    func printAlbum() {
        print("\(self.name) by \(self.artist) (\(self.price))")
    }
    
    func getAlbumURLorGoogle() -> NSURL {
        
        guard self.url != nil
            else { return NSURL(string: "http://www.google.com")! }
        return self.url!
    }

}
