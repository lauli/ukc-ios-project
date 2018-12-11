//
//  PhotoManager.swift
//  EL882Workshop5
//
//  Created by Laureen Schausberger on 11/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import Foundation
import UIKit

final class DataManager {
    
    // singleton
    static let shared: DataManager = DataManager()
    
    // url information, keys
    private let basicUrl = "https://gateway.marvel.com:443/v1/public/"
    private let apiKey = "d932666c3ae84f7d478dd9c80b94c47e"
    private let apiKeyPrivate = "9331ddfc7675d4f5cb96752968f46a20e0490778"
    private let timeStamp = NSDate.timeIntervalSinceReferenceDate
    private var hash: String = ""
    
    // retrieved data
    var characters = [Character]()
    var comics = [Comic]()
    var creators = [Creator]()
    
    // counters
    var totalAmountInDB = [String: Int]()
    private var alreadyRequestedAmount = [String: Int]()
    
    // data types
    typealias Success = (Bool) -> ()
    typealias RetrievedData = (Int, Bool) -> ()
    typealias ImageData = (UIImage?, Bool) -> ()
    typealias DetailArrayData = ([MarvelObject]?, Bool) -> ()
    typealias SearchData = (MarvelObject?, Bool) -> ()
    
    init() {
        hash = md5("\(timeStamp)" + apiKeyPrivate + apiKey)
    }
    
    // MARK: - DATA REQUESTS
    // MARK: -Request basic information
    
    func request(type: Type, amountOfObjectsToRequest amount: Int = 30, completion: @escaping RetrievedData) {
        
        let skip = alreadyRequestedAmount[type.rawValue] ?? 0
        let orderBy: String
        
        switch type {
        case .comics:
            orderBy = "title"
        case .characters:
            orderBy = "name"
        case .creators:
            orderBy = "firstName"
        }
        
        var url = "https://gateway.marvel.com:443/v1/public/"
        url.append(type.rawValue + "?")
        url.append("orderBy=" + orderBy)
        url.append("&limit=\(amount)")
        url.append("&offset=\(skip+1)")
        url.append("&ts=\(timeStamp)")
        url.append("&apikey=" + apiKey)
        url.append("&hash=" + hash)
        
        let dataTask = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            guard let data = data else {
                print("DataManger > Couldn't fetch data from URL.")
                print(error?.localizedDescription as Any)
                return
            }
            
            let oldCountOfObjects: Int
            switch type {
            case .comics:
                oldCountOfObjects = self.comics.count
            case .characters:
                oldCountOfObjects = self.characters.count
            case .creators:
                oldCountOfObjects = self.creators.count
            }
            
            self.decodeBasicData(data, forType: type) { success in
                if success {
                    let oldAlreadyRequestedAmount = self.alreadyRequestedAmount[type.rawValue] ?? 0
                    self.alreadyRequestedAmount[type.rawValue] = oldAlreadyRequestedAmount + amount
                    
                    let amountOfFetchedObjects: Int
                    switch type {
                    case .comics:
                        amountOfFetchedObjects = self.comics.count - oldCountOfObjects
                    case .characters:
                        amountOfFetchedObjects = self.characters.count - oldCountOfObjects
                    case .creators:
                        amountOfFetchedObjects = self.creators.count - oldCountOfObjects
                    }
                    completion(amountOfFetchedObjects, success)
                }
                completion(0, false)
            }
        }
        
        dataTask.resume()
    }
    
    private func decodeBasicData(_ data: Data, forType type: Type, completion: @escaping Success) {
        
        guard let (resultsArray, totalAmount) = resultsOfJSONDecoding(forData: data) else {
            completion(false)
            return
        }
        
        totalAmountInDB[type.rawValue] = totalAmount
        
        guard let results = resultsArray as? [Any] else {
            completion(false)
            return
        }
        
        let nameKey: String
        
        switch type {
        case .comics:
            nameKey = "title"
        case .characters:
            nameKey = "name"
        case .creators:
            nameKey = "fullName"
        }
        
        for result in results {
            guard let object = result as? [String: Any],
                let id = object["id"] as? Int,
                let name = object["\(nameKey)"] as? String,
                let thumbnailInfo = object["thumbnail"] as? [String: String],
                let imagePath = thumbnailInfo["path"],
                let imageExtension = thumbnailInfo["extension"] else {
                    print("DataManger > decodeData() -> Couldn't retrieve exact data from JSON.")
                    completion(false)
                    return
            }
            if imagePath == "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available" {
                // the database doesn't have a picture, therefore we wanna skip the object
                continue
            }
            let imageUrl = imagePath + "." + imageExtension
            
            switch type {
            case .comics:
                comics.append(Comic(id: id, name: name, thumbnail: imageUrl))
            case .characters:
                characters.append(Character(id: id, name: name, thumbnail: imageUrl))
            case .creators:
                creators.append(Creator(id: id, name: name, thumbnail: imageUrl))
            }
        }
        
        completion(true)
    }
    
    private func resultsOfJSONDecoding(forData data: Data) -> (Any, Int)? {
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
    
    // MARK: -Request Image
    
    func requestImage(forImageUrl url: String, completion: @escaping ImageData) {
        let dataTask = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            guard let data = data, error == nil else {
                print("DataManager > requestImage() image downloader, data or response nil for url: \(url)")
                completion(nil, false)
                return
            }
            
            if let image = UIImage(data: data) {
                completion(image, true)
            } else {
                completion(nil, false)
            }
        }
        dataTask.resume()
    }
    
    // MARK: -Request Standalone Character
    
    func requestCharacterDetails(forId id: Int, atIndex index: Int, completion: @escaping Success) {
        
        var url = "https://gateway.marvel.com:443/v1/public/characters?"
        url.append("id=\(id)")
        url.append("&ts=\(timeStamp)")
        url.append("&apikey=" + apiKey)
        url.append("&hash=" + hash)
        
        let dataTask = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            guard let data = data else {
                print("DataManger > Couldn't fetch data from URL.")
                print(error?.localizedDescription as Any)
                return
            }
            
            guard let (resultsArray, _) = self.resultsOfJSONDecoding(forData: data) else {
                completion(false)
                return
            }
            
            guard let results = resultsArray as? [Any] else {
                completion(false)
                return
            }
            
            for result in results {
                // get detail info
                guard let character = result as? [String: Any],
                    let name = character["name"] as? String,
                    let description = character["description"] as? String?,
                    let comicList = character["comics"] as? [String: Any] else {
                        print("DataManger > Couldn't retrieve exact data from JSON for character details.")
                        completion(false)
                        return
                }
                
                // get comic info
                guard let comicTotal = comicList["available"] as? Int?,
                    let collectionURI = comicList["collectionURI"] as? String?,
                    let firstComics = comicList["items"] as? [Any] else {
                        print("DataManger > Couldn't retrieve exact data from JSON for character details > comics.")
                        completion(false)
                        return
                }
                
                // get array of comic names
                var comics = [String]()
                for comic in firstComics {
                    
                    guard let c = comic as? [String: Any],
                        let name = c["name"] as? String else {
                            print("DataManger > Couldn't retrieve exact data from JSON for character details > comic name.")
                            completion(false)
                            return
                    }
                    comics.append(name)
                }
                
                // adding Details to character in character array
                if self.characters[index].name == name {
                    self.characters[index].details = Character.Details(description: description, amountOfComics: comicTotal, comics: comics, url: collectionURI)
                }
                
            }
            completion(true)
            
        }
        
        dataTask.resume()
    }
    
    // MARK: -Request Standalone Comic
    
    func requestComicDetails(forId id: Int, atIndex index: Int, completion: @escaping Success) {
        
        var url = "https://gateway.marvel.com:443/v1/public/comics?"
        url.append("id=\(id)")
        url.append("&ts=\(timeStamp)")
        url.append("&apikey=" + apiKey)
        url.append("&hash=" + hash)
        
        let dataTask = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            guard let data = data else {
                print("DataManger > Couldn't fetch data from URL.")
                print(error?.localizedDescription as Any)
                return
            }
            
            guard let (resultsArray, _) = self.resultsOfJSONDecoding(forData: data) else {
                completion(false)
                return
            }
            
            guard let results = resultsArray as? [Any] else {
                completion(false)
                return
            }
            
            for result in results {
                // get detail info
                guard let comic = result as? [String: Any],
                    let name = comic["title"] as? String,
                    let description = comic["description"] as? String?,
                    let format = comic["format"] as? String?,
                    let pageCount = comic["pageCount"] as? Int?,
                    let issueNumber = comic["issueNumber"] as? Double?,
                    let characterList = comic["characters"] as? [String: Any],
                    let creatorList = comic["creators"] as? [String: Any] else {
                        print("DataManger > Couldn't retrieve exact data from JSON for character details.")
                        completion(false)
                        return
                }
                
                // get character info
                guard let characterTotal = characterList["available"] as? Int?,
                    let firstCharacters = characterList["items"] as? [Any] else {
                        print("DataManger > Couldn't retrieve exact data from JSON for character details > character.")
                        completion(false)
                        return
                }
                
                // get array of character names
                var characters = [String]()
                for character in firstCharacters {
                    
                    guard let c = character as? [String: Any],
                        let name = c["name"] as? String else {
                            print("DataManger > Couldn't retrieve exact data from JSON for character details > character name.")
                            completion(false)
                            return
                    }
                    characters.append(name)
                }
                
                // get creator info
                guard let creatorTotal = creatorList["available"] as? Int?,
                    let firstCreators = creatorList["items"] as? [Any] else {
                        print("DataManger > Couldn't retrieve exact data from JSON for character details > creator.")
                        completion(false)
                        return
                }
                
                // get array of creator names
                var creators = [String]()
                for creator in firstCreators {
                    
                    guard let c = creator as? [String: Any],
                        let name = c["name"] as? String else {
                            print("DataManger > Couldn't retrieve exact data from JSON for character details > creator name.")
                            completion(false)
                            return
                    }
                    creators.append(name)
                }
                
                // adding Details to character in character array
                if self.comics[index].name == name {
                    self.comics[index].description = description
                    self.comics[index].format = format
                    self.comics[index].issueNumber = Int(issueNumber ?? 0)
                    self.comics[index].pages = pageCount
                    self.comics[index].characterTotal = characterTotal
                    self.comics[index].creatorTotal = creatorTotal
                    self.comics[index].characters = characters
                    self.comics[index].creators = creators
                }
                
            }
            completion(true)
            
        }
        
        dataTask.resume()
    }
    
    
    // MARK: -Request Details for Objects
    
    func requestDataForDetailCollectionView(about type: Type, from marvelObject: MarvelObject, completion: @escaping DetailArrayData) {
        switch type {
        case .comics:
            if let marvelObject = marvelObject as? Character,
                let comicNames = marvelObject.details?.comics {
                
                var counter = 1
                var returnedComics = [Comic]()
                
                for comicName in comicNames {
                    searchForType(.comics, name: comicName) { returnedValue, success in
                        counter += 1
                        
                        if success, let comic = returnedValue as? Comic {
                            returnedComics.append(comic)
                        }
                        
                        if counter == comicNames.count {
                            completion(returnedComics, true)
                        }
                    }
                }
                
                
            } else if let _ = marvelObject as? Creator {
                completion(nil, false)
            }
            
        case .characters:
            if let marvelObject = marvelObject as? Comic,
                let comicNames = marvelObject.characters {
                
                var counter = 1
                var returnedCharacters = [Character]()
                
                for comicName in comicNames {
                    searchForType(.comics, name: comicName) { returnedValue, success in
                        counter += 1
                        
                        if success, let comic = returnedValue as? Character {
                            returnedCharacters.append(comic)
                        }
                        
                        //if counter == comicNames.count {
                        completion(returnedCharacters, true)
                        //}
                    }
                }
                
                
            } else if let _ = marvelObject as? Creator {
                completion(nil, false)
            }
            
        case .creators:
            if let marvelObject = marvelObject as? Comic,
                let creatorNames = marvelObject.creators {
                
                var counter = 1
                var returnedCreators = [Creator]()
                
                for creatorName in creatorNames {
                    searchForType(.creators, name: creatorName) { returnedValue, success in
                        counter += 1
                        
                        if success, let creator = returnedValue as? Creator {
                            returnedCreators.append(creator)
                        }
                        
                        //if counter == comicNames.count {
                        completion(returnedCreators, true)
                        //}
                    }
                }
                
                
            }
        }
        
        completion(nil, false)
    }
    
    private func searchForType(_ type: Type, name: String, completion: @escaping SearchData) {
        // check if name needs to be converted to utf-8
        guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
                completion(nil, false)
                return
        }
        
        let nameKey: String
        
        switch type {
        case .comics:
            nameKey = "title"
        case .characters:
            nameKey = "name"
        case .creators:
            nameKey = "nameStartsWith"
        }
        
        var url = "https://gateway.marvel.com:443/v1/public/"
        url.append(type.rawValue + "?")
        url.append("\(nameKey)=\(encodedName)")
        url.append("&ts=\(timeStamp)")
        url.append("&apikey=" + apiKey)
        url.append("&hash=" + hash)
        
        guard let encodedURL = URL(string: url) else {
            completion(nil, false)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: encodedURL) { data, response, error in
            guard let data = data else {
                print("DataManger > Couldn't fetch data from URL.")
                print(error?.localizedDescription as Any)
                completion(nil, false)
                return
            }
            
            guard let (resultsArray, _) = self.resultsOfJSONDecoding(forData: data) else {
                completion(nil, false)
                return
            }
            
            guard let results = resultsArray as? [Any] else {
                completion(nil, false)
                return
            }
            
            let nameKey: String
            
            switch type {
            case .comics:
                nameKey = "title"
            case .characters:
                nameKey = "name"
            case .creators:
                nameKey = "fullName"
            }
            
            guard let object = results.first as? [String: Any],
                let id = object["id"] as? Int,
                let name = object["\(nameKey)"] as? String,
                let thumbnailInfo = object["thumbnail"] as? [String: String],
                let imagePath = thumbnailInfo["path"],
                let imageExtension = thumbnailInfo["extension"] else {
                    print("DataManger > decodeData() -> Couldn't retrieve exact data from JSON.")
                    completion(nil, false)
                    return
            }

            let imageUrl = imagePath + "." + imageExtension
            
            switch type {
            case .comics:
                completion(Comic(id: id, name: name, thumbnail: imageUrl), true)
            case .characters:
                completion(Character(id: id, name: name, thumbnail: imageUrl), true)
            case .creators:
                completion(Creator(id: id, name: name, thumbnail: imageUrl), true)
            }
            
        }
        
        dataTask.resume()
    }
    
}

extension DataManager {
    
    private func md5(_ string: String) -> String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate()
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        return hexString
    }
    
}


extension String {
    func utf8DecodedString()-> String {
        let data = self.data(using: .utf8)
        if let message = String(data: data!, encoding: .nonLossyASCII){
            return message
        }
        return ""
    }
    
    func utf8EncodedString()-> String {
        let messageData = self.data(using: .nonLossyASCII)
        let text = String(data: messageData!, encoding: .utf8)!
        return text
    }
}
