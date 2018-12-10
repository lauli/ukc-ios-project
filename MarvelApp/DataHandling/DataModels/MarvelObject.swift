//
//  MarvelObject.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 13/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import Foundation

class MarvelObject {
    // must haves
    let id: Int
    let name: String
    let thumbnail: String?
    
    init(id: Int, name: String, thumbnail: String?) {
        self.id = id
        self.name = name
        self.thumbnail = thumbnail
    }
}
