//
//  Comic.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 13/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import Foundation

final class Comic: MarvelObject {
    
    // additional information
    var description, format: String?
    var issueNumber, pages, price: Int?
    var creators: [String]? // id for creators
    var characters: [String]? // id for characters
    
    init(id: Int, name: String, thumbnail: String? = nil,
         description: String? = nil, format: String? = nil,
         issueNumber: Int? = nil, pages: Int? = nil, price: Int? = nil,
         creators: [String]? = nil, characters: [String]? = nil) {
        
        super.init(id: id, name: name, thumbnail: thumbnail)
        self.description = description
        self.format = format
        self.issueNumber = issueNumber
        self.pages = pages
        self.price = price
        self.creators = creators
        self.characters = characters
    }
}
