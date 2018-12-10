//
//  Creator.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 13/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit

final class Creator: MarvelObject {
    
    var suffix: String?
    var urls: [String]?
    
    init(id: Int, name: String, thumbnail: String?,
         suffix: String? = nil, urls: [String]? = nil  ) {
        
        super.init(id: id, name: name, thumbnail: thumbnail)
        
        self.suffix = suffix
        self.urls = urls
    }
}
