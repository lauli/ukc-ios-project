//
//  Superhero.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 13/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import Foundation

final class Character: MarvelObject {
    var comicTotal: Int? // amount of comics this character appears in
    var url: String? // url to all comics
    
    init(id: Int, name: String, thumbnail: String?) {
        super.init(type: .characters, id: id, name: name, thumbnail: thumbnail)
    }
}
