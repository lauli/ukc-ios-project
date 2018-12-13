//
//  Comic.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 13/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import Foundation

final class Comic: MarvelObject {
    var format: String?
    var characterTotal, creatorTotal, issueNumber, pages, price: Int? // TODO: prices is an own class. do i want to implement this as well?
    
    init(id: Int, name: String, thumbnail: String?) {
        super.init(type: .comics, id: id, name: name, thumbnail: thumbnail)
    }
}
