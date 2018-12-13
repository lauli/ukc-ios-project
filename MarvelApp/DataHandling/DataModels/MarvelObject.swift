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
    let type: Type
    let id: Int
    let name: String
    let thumbnail: String?
    
    // additional information
    var description: String? = nil
    var comics: [String]? = nil // name for first 20 comics, or less
    var characters: [String]? = nil // name for first 20 characters, or less
    var creators: [String]? = nil // name for first 20 creators, or less
    
    init(type: Type, id: Int, name: String, thumbnail: String?) {
        self.type = type
        self.id = id
        self.name = name
        self.thumbnail = thumbnail
    }

}
