//
//  Creator.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 13/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit

final class Creator: MarvelObject {
    var suffix: String? = nil
    var comicTotal: Int? // amount of comics this character appears in
    
    init(id: Int, name: String, thumbnail: String?) {
        super.init(type: .creators, id: id, name: name, thumbnail: thumbnail)
    }
}
