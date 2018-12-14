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
    
    private let decoder = Decoder()
    
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
        
        guard let (resultsArray, totalAmount) = decoder.results(forData: data) else {
            completion(false)
            return
        }
        
        totalAmountInDB[type.rawValue] = totalAmount
        
        guard let results = resultsArray as? [Any] else {
            completion(false)
            return
        }
        
        for result in results {
            guard let object = result as? [String: Any], let marvelObject = self.decoder.basicObjectInformation(fromJSON: object, forType: type) else {
                print("DataManger > decodeBasicData -> Couldn't retrieve exact data from JSON.")
                completion(false)
                return
            }
            if marvelObject.thumbnail == "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg" {
                // the database doesn't have a picture, therefore we wanna skip the object
                continue
            }
            
            switch type {
            case .comics:
                comics.append(Comic(id: marvelObject.id, name: marvelObject.name, thumbnail: marvelObject.thumbnail))
                comics.sort(by: { $0.name < $1.name })
            case .characters:
                characters.append(Character(id: marvelObject.id, name: marvelObject.name, thumbnail: marvelObject.thumbnail))
                characters.sort(by: { $0.name < $1.name })
            case .creators:
                creators.append(Creator(id: marvelObject.id, name: marvelObject.name, thumbnail: marvelObject.thumbnail))
                creators.sort(by: { $0.name < $1.name })
            }
        }
        
        completion(true)
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
    
    // MARK: -Request Standalone Comic
    
    func requestDetails(forObject object: MarvelObject, atArrayIndex index: Int, completion: @escaping Success) {
        
        var url = "https://gateway.marvel.com:443/v1/public/\(object.type.rawValue)?"
        url.append("id=\(object.id)")
        url.append("&ts=\(timeStamp)")
        url.append("&apikey=" + apiKey)
        url.append("&hash=" + hash)
        
        let dataTask = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            guard let data = data else {
                print("DataManger > Couldn't fetch data from URL.")
                print(error?.localizedDescription as Any)
                return
            }
            
            guard let (JSONDecoded, _) = self.decoder.results(forData: data),
                let jsonList = JSONDecoded as? [Any] else {
                    completion(false)
                    return
            }
            
            for result in jsonList {
                // get detail info
                
                guard let json = result as? [String: Any] else {
                    print("DataManger > requestDetails > Couldn't retrieve data from JSON for details.")
                    completion(false)
                    return
                }
                
                switch object.type {
                case .comics:
                    if let (name, newObject) = self.decoder.comicDetails(fromJSON: json, addToOldObject: object as! Comic),
                        self.comics[index].name == name {
                        self.comics[index] = newObject
                    }
                    
                case .characters:
                    if let (name, newObject) = self.decoder.characterDetails(fromJSON: json, addToOldObject: object as! Character),
                        self.characters[index].name == name {
                        self.characters[index] = newObject
                    }
                    
                case .creators:
                    if let (name, newObject) = self.decoder.creatorDetails(fromJSON: json, addToOldObject: object as! Creator),
                        self.creators[index].name == name {
                        self.creators[index] = newObject
                    }
                }
                
            }
            completion(true)
            
        }
        
        dataTask.resume()
    }
    
    
    
    
    
    
    // MARK: -Request Data from Detailobjects for DetailCollectionView
    
    func requestDataForDetailCollectionView(about type: Type, from marvelObject: MarvelObject, completion: @escaping DetailArrayData) {
        
        var array: [MarvelObject]
        
        switch type {
        case .comics:
            array = [Comic]()
        case .characters:
            array = [Character]()
        case .creators:
            array = [Creator]()
        }
        
        switch type {
        case .comics:
            if let comicNames = marvelObject.comics {
                for comicName in comicNames {
                    search(forType: .comics, byName: comicName) { returnedValue, success in
                        if success, let comic = returnedValue as? Comic {
                            array.append(comic)
                        }
                        completion(array, true)
                    }
                }
            } else {
                completion(nil, false)
                return
            }
            
        case .characters:
            if let characterNames = marvelObject.characters {
                for characterName in characterNames {
                    search(forType: .characters, byName: characterName) { returnedValue, success in
                        if success, let comic = returnedValue as? Character {
                            array.append(comic)
                        }
                        completion(array, true)
                    }
                }
            } else {
                completion(nil, false)
                return
            }
            
        case .creators:
            if let creatorNames = marvelObject.creators {
                for creatorName in creatorNames {
                    search(forType: .creators, byName: creatorName) { returnedValue, success in
                        if success, let comic = returnedValue as? Creator {
                            array.append(comic)
                        }
                        completion(array, true)
                    }
                }
            } else {
                completion(nil, false)
                return
            }
        }
    }
    
    private func search(forType type: Type, byName name: String, completion: @escaping SearchData) {
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
            
            guard let object = self.decoder.dataToResult(data: data) as? [String: Any],
                let marvelObject = self.decoder.basicObjectInformation(fromJSON: object, forType: type) else {
                    print("DataManger > decodeBasicData -> Couldn't retrieve exact data from JSON.")
                    completion(nil, false)
                    return
            }
            
            switch type {
            case .comics:
                completion(Comic(id: marvelObject.id, name: marvelObject.name, thumbnail: marvelObject.thumbnail), true)
            case .characters:
                completion(Character(id: marvelObject.id, name: marvelObject.name, thumbnail: marvelObject.thumbnail), true)
            case .creators:
                completion(Creator(id: marvelObject.id, name: marvelObject.name, thumbnail: marvelObject.thumbnail), true)
            }
        }
        
        dataTask.resume()
    }
    
    // MARK: -Request Data from Favorites for DetailCollectionView
    
    func requestDataForDetailCollectionView(about type: Type, byIds ids: [Int], completion: @escaping DetailArrayData) {
        var array: [MarvelObject]
        
        switch type {
        case .comics:
            array = [Comic]()
        case .characters:
            array = [Character]()
        case .creators:
            array = [Creator]()
        }
        
        for id in ids {
            search(forType: type, byId: id) { returnedValue, success in
                if success, let value = returnedValue {
                    array.append(value)
                }
                completion(array, true)
            }
        }
        
    }
    
    private func search(forType type: Type, byId id: Int, completion: @escaping SearchData) {
        
        var url = "https://gateway.marvel.com:443/v1/public/"
        url.append("\(type.rawValue)/")
        url.append("\(id)?")
        url.append("&ts=\(timeStamp)")
        url.append("&apikey=" + apiKey)
        url.append("&hash=" + hash)
        
        guard let encodedURL = URL(string: url) else {
            completion(nil, false)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: encodedURL) { data, response, error in
            
            guard let object = self.decoder.dataToResult(data: data) as? [String: Any],
                let marvelObject = self.decoder.basicObjectInformation(fromJSON: object, forType: type) else {
                    print("DataManger > decodeBasicData -> Couldn't retrieve exact data from JSON.")
                    completion(nil, false)
                    return
            }
            
            switch type {
            case .comics:
                completion(Comic(id: marvelObject.id, name: marvelObject.name, thumbnail: marvelObject.thumbnail), true)
            case .characters:
                completion(Character(id: marvelObject.id, name: marvelObject.name, thumbnail: marvelObject.thumbnail), true)
            case .creators:
                completion(Creator(id: marvelObject.id, name: marvelObject.name, thumbnail: marvelObject.thumbnail), true)
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

