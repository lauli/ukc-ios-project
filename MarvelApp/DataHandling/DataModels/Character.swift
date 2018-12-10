//
//  Superhero.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 13/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import Foundation

final class Character: MarvelObject {
    
    // additional information
    var details: Details? = nil
    
    init(id: Int, name: String, thumbnail: String?, additionalInfo: Details? = nil) {
        super.init(id: id, name: name, thumbnail: thumbnail)
        
        if let details = additionalInfo {
            self.details = details
        }
    }
    
    class Details {
        var description: String?
        var amountOfComics: Int? // amount of comics this character appears in
        var comics: [String]? // name for first 20 comics, or less
        var url: String? // url to all comics
        
        init(description: String? = nil, amountOfComics: Int? = nil, comics: [String]? = nil, url: String? = nil) {
            self.description = description
            self.amountOfComics = amountOfComics
            self.comics = comics
            self.url = url
        }
    }
}
