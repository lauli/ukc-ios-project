//
//  Decoder.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 13/12/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import Foundation

final class Decoder {
    
    func results(forData data: Data) -> (Any, Int)? {
        do {
            guard let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                print("json -> Not a [String: Any]")
                return nil
            }
            
            guard let code = jsonData["code"] as? Int, code == 200 else {
                print("code is not 200")
                return nil
            }
            
            guard let data = jsonData["data"] as? [String: Any] else {
                print("data -> Not a [String: Any]")
                return nil
            }
            
            guard let results = data["results"] as? [Any] else {
                print("results -> Not a [String: Any]")
                return nil
            }
            
            guard let totalCount = data["total"] as? Int else {
                print("total -> Not an Int")
                return nil
            }
            
            return (results, totalCount)
            
        } catch let error {
            print("Decoding error: " + error.localizedDescription)
            return nil
        }
    }
    
    func dataToResult(data: Data?) -> [Any]? {
        guard let data = data else {
            print("DataManger > Couldn't fetch data from URL.")
            return nil
        }
        
        guard let (resultsArray, _) = results(forData: data),
            let results = resultsArray as? [Any] else {
            return nil
        }
        
        return results
    }
    
    func basicObjectInformation(fromJSON json: [String: Any], forType type: Type) -> MarvelObject? {
        let nameKey: String
        switch type {
        case .comics:
            nameKey = "title"
        case .characters:
            nameKey = "name"
        case .creators:
            nameKey = "fullName"
        }
        
        guard let id = json["id"] as? Int,
            let name = json["\(nameKey)"] as? String,
            let thumbnailInfo = json["thumbnail"] as? [String: String],
            let imagePath = thumbnailInfo["path"],
            let imageExtension = thumbnailInfo["extension"] else {
                print("DataManger > decodeData() -> Couldn't retrieve exact data from JSON.")
                return nil
        }
        return MarvelObject(type: type, id: id, name: name, thumbnail: imagePath + "." + imageExtension)
    }
    
    // returns name of comic (String) and the decoded object with details (Comic)
    func comicDetails(fromJSON json: [String: Any], addToOldObject old: Comic) -> (String, Comic)? {
        guard let name = json["title"] as? String,
            let format = json["format"] as? String?,
            let pageCount = json["pageCount"] as? Int?,
            let issueNumber = json["issueNumber"] as? Double?,
            let characterList = json["characters"] as? [String: Any],
            let creatorList = json["creators"] as? [String: Any] else {
                print("DataManger > decodeComicDetails > Couldn't retrieve exact data from JSON for details.")
                return nil
        }
        
        
        let description: String
        // no idea why, but sometimes it doesnt get the description even if its String?
        // that's why I am sorting it out this way
        if let d = json["description"] as? String {
            description = d
        } else {
            description = ""
        }
        
        let (characterTotal, characters) = self.decodeDetailsToStringArray(fromList: characterList)
        let (creatorTotal, creators) = self.decodeDetailsToStringArray(fromList: creatorList)
        
        if old.name == name {
            old.description = description.utf8DecodedString()
            old.format = format
            old.issueNumber = Int(issueNumber ?? 0)
            old.pages = pageCount
            old.characterTotal = characterTotal
            old.creatorTotal = creatorTotal
            old.characters = characters
            old.creators = creators
        }
        
        return (name, old)
    }
    
    // returns name of character (String) and the decoded object with details (Character)
    func characterDetails(fromJSON json: [String: Any], addToOldObject old: Character) -> (String, Character)? {
        guard let name = json["name"] as? String,
            let description = json["description"] as? String?,
            let comicList = json["comics"] as? [String: Any] else {
                print("DataManger > decodeCharacterDetails > Couldn't retrieve exact data from JSON for details.")
                return nil
        }
        
        let (comicTotal, comics) = self.decodeDetailsToStringArray(fromList: comicList)
        
        if old.name == name {
            old.description = description?.utf8DecodedString()
            old.comicTotal = comicTotal
            old.comics = comics
        }
        
        return (name, old)
    }
    
    // returns name of creator (String) and the decoded object with details (Comic)
    func creatorDetails(fromJSON json: [String: Any], addToOldObject old: Creator) -> (String, Creator)? {
        guard let name = json["fullName"] as? String,
            let suffix = json["suffix"] as? String?,
            let comicList = json["comics"] as? [String: Any] else {
                print("DataManger > decodeCreatorDetails > Couldn't retrieve exact data from JSON for details.")
                return nil
        }
        
        let (comicTotal, comics) = self.decodeDetailsToStringArray(fromList: comicList)
        
        if old.name == name {
            old.suffix = suffix
            old.comicTotal = comicTotal
            old.comics = comics
        }
        
        return (name, old)
    }
    
    // return the totalAmount (Int?) and the retrieved Objects ([String])
    private func decodeDetailsToStringArray(fromList list: [String: Any]) -> (Int?, [String]) {
        var array = [String]()
        
        guard let total = list["available"] as? Int?,
            let listItems = list["items"] as? [Any] else {
                print("DataManger > decodeMarvelObjectArray > Couldn't retrieve exact data from JSON for details.")
                return (0, array)
        }
        
        for object in listItems {
            if let objectDictionary = object as? [String: Any], let name = objectDictionary["name"] as? String {
                array.append(name)
            }
        }
        return (total, array)
    }
}
