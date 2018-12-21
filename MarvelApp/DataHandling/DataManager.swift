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
    typealias ImageData = (UIImage?, String?) -> ()
    typealias DetailArrayData = ([MarvelObject]?, Bool) -> ()
    typealias SearchData = (MarvelObject?, Bool) -> ()
    
    init() {
        hash = md5("\(timeStamp)" + apiKeyPrivate + apiKey)
    }
    
    // MARK: - DATA REQUESTS
    // MARK: -Request basic information
    
    func request(type: Type, amountOfObjectsToRequest amount: Int = 30, completion: @escaping RetrievedData) {
        
        let dataTask = URLSession.shared.dataTask(with: URL(string: urlForFetchingMoreData(amount: amount, type: type))!) { data, response, error in
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
                if !comics.contains(where: { $0.id == marvelObject.id }) {
                    comics.append(Comic(id: marvelObject.id, name: marvelObject.name, thumbnail: marvelObject.thumbnail))
                    comics.sort(by: { $0.name < $1.name })
                }
            case .characters:
                if !characters.contains(where: { $0.id == marvelObject.id }) {
                    characters.append(Character(id: marvelObject.id, name: marvelObject.name, thumbnail: marvelObject.thumbnail))
                    characters.sort(by: { $0.name < $1.name })
                }
            case .creators:
                if !creators.contains(where: { $0.id == marvelObject.id }) {
                    creators.append(Creator(id: marvelObject.id, name: marvelObject.name, thumbnail: marvelObject.thumbnail))
                    creators.sort(by: { $0.name < $1.name })
                }
            }
        }
        
        completion(true)
    }
    
    
    
    // MARK: -Request Image
    
    func requestImage(forImageUrl url: String, completion: @escaping ImageData) {
        let dataTask = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            guard let data = data, error == nil else {
                print("DataManager > requestImage() image downloader, data or response nil for url: \(url)")
                completion(nil, nil)
                return
            }
            
            if let image = UIImage(data: data) {
                completion(image, url)
            } else {
                completion(nil, nil)
            }
        }
        dataTask.resume()
    }
    
    // MARK: -Request Details of a specific object
    
    func requestDetails(forObject object: MarvelObject, atArrayIndex index: Int, completion: @escaping SearchData) {
        
        let dataTask = URLSession.shared.dataTask(with: URL(string: urlForDetailsById(object.id, type: object.type))!) { data, response, error in
            guard let data = data else {
                print("DataManger > Couldn't fetch data from URL.")
                print(error?.localizedDescription as Any)
                return
            }
            
            guard let (JSONDecoded, _) = self.decoder.results(forData: data),
                let jsonList = JSONDecoded as? [Any] else {
                    completion(nil, false)
                    return
            }
            
            for result in jsonList {
                // get detail info
                
                guard let json = result as? [String: Any] else {
                    print("DataManger > requestDetails > Couldn't retrieve data from JSON for details.")
                    completion(nil, false)
                    return
                }
                
                switch object.type {
                case .comics:
                    if let (name, newObject) = self.decoder.comicDetails(fromJSON: json, addToOldObject: object as! Comic) {
                        if index < self.comics.count, self.comics[index].name == name {
                            self.comics[index] = newObject
                        }
                        completion(newObject, true)
                    }
                    
                case .characters:
                    if let (name, newObject) = self.decoder.characterDetails(fromJSON: json, addToOldObject: object as! Character) {
                        if index < self.characters.count, self.characters[index].name == name {
                            self.characters[index] = newObject
                        }
                        completion(newObject, true)
                    }
                    
                case .creators:
                    if let (name, newObject) = self.decoder.creatorDetails(fromJSON: json, addToOldObject: object as! Creator) {
                        if index < self.creators.count, self.creators[index].name == name {
                            self.creators[index] = newObject
                        }
                        completion(newObject, true)
                    }
                }
            }
        }
        
        dataTask.resume()
    }
    
    // MARK: -Search and request Objects that have the same name as stored in parameter names
    
    func requestDataForDetailCollectionView(about type: Type, from names: [String]?, forSearchTab: Bool = false, completion: @escaping DetailArrayData) {
        
        guard let arrayOfNames = names else {
            completion(nil, false)
            return
        }
        
        var array = [MarvelObject]()
        
        if forSearchTab {
            for name in arrayOfNames {
                searchFromSearchTab(forType: type, byName: name) { returnedValue, success in
                    if success, let comic = returnedValue {
                        array.append(comic)
                    }
                    
                    array.sort(by: { $0.name < $1.name })
                    completion(array, true)
                }
            }
            
        } else {
            for name in arrayOfNames {
                search(forType: type, byName: name) { returnedValue, success in
                    if success, let comic = returnedValue {
                        array.append(comic)
                    }
                    
                    array.sort(by: { $0.name < $1.name })
                    completion(array, true)
                }
            }
        }
        
    }
    
    
    private func searchFromSearchTab(forType type: Type, byName name: String, completion: @escaping SearchData) {
        // check if name needs to be converted to utf-8
        guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let encodedURL = URL(string: urlForSearchNameFromSearchTab(encodedName, type: type)) else {
                completion(nil, false)
                return
        }
        
        search(url: encodedURL, forType: type) { data, success in
            completion(data, success)
        }
    }
    
    private func search(forType type: Type, byName name: String, completion: @escaping SearchData) {
        // check if name needs to be converted to utf-8
        guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let encodedURL = URL(string: urlForSearchNameFromMarvelobject(encodedName, type: type)) else {
                completion(nil, false)
                return
        }
        
        search(url: encodedURL, forType: type) { data, success in
            completion(data, success)
        }
    }
    
    
    private func search(url: URL, forType type: Type, completion: @escaping SearchData) {
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let results = self.decoder.dataToResult(data: data) else {
                print("DataManger > decodeBasicData -> Couldn't retrieve data from JSON.")
                completion(nil, false)
                return
            }
            
            if results.isEmpty {
                completion(nil, true)
                return
            }
            
            for result in results {
                guard let object = result as? [String: Any], let marvelObject = self.decoder.basicObjectInformation(fromJSON: object, forType: type) else {
                    print("DataManger > decodeBasicData -> Couldn't retrieve data from JSON result.")
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
        }
        
        dataTask.resume()
    }
    
    // MARK: -Request Data from Favorites for DetailCollectionView
    
    func requestDataForDetailCollectionView(about type: Type, byIds ids: [Int], completion: @escaping DetailArrayData) {
        var array = [MarvelObject]()
        
        for id in ids {
            search(forType: type, byId: id) { returnedValue, success in
                if success, let value = returnedValue {
                    array.append(value)
                }
                array.sort(by: { $0.name < $1.name })
                completion(array, true)
            }
        }
        
    }
    
    private func search(forType type: Type, byId id: Int, completion: @escaping SearchData) {
        
        guard let encodedURL = URL(string: urlForSearchId(id, type: type)) else {
            completion(nil, false)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: encodedURL) { data, response, error in
            
            guard let object = self.decoder.dataToResult(data: data)?.first as? [String: Any],
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
    
    //    private func emptyArrayByType(_ type: MarvelType)
    
}

extension DataManager {
    
    private var authorisation: String {
        var url = "&ts=\(timeStamp)"
        url.append("&apikey=" + apiKey)
        url.append("&hash=" + hash)
        return url
    }
    
    private func urlForSearchId(_ input: Int, type: Type) -> String {
        var url = basicUrl + type.rawValue
        url.append("/" + "\(input)")
        url.append("?" + authorisation)
        return url
    }
    
    private func urlForSearchNameFromSearchTab(_ input: String, type: Type) -> String {
        switch type {
        case .comics:
            return urlForSearchName(input, type: type, nameKey: "titleStartsWith")
        case .characters, .creators:
            return urlForSearchName(input, type: type, nameKey: "nameStartsWith")
        }
    }
    
    private func urlForSearchNameFromMarvelobject(_ input: String, type: Type) -> String {
        switch type {
        case .comics:
            return urlForSearchName(input, type: type, nameKey: "title")
        case .characters:
            return urlForSearchName(input, type: type, nameKey: "name")
        case .creators:
            return urlForSearchName(input, type: type, nameKey: "nameStartsWith")
        }
    }
    
    private func urlForSearchName(_ input: String, type: Type, nameKey: String) -> String {
        var url = basicUrl + type.rawValue
        url.append("?" + nameKey + "=" + input)
        url.append(authorisation)
        return url
    }
    
    private func urlForDetailsById(_ input: Int, type: Type) -> String {
        var url = basicUrl + type.rawValue
        url.append("?id=" + "\(input)")
        url.append(authorisation)
        return url
    }
    
    private func urlForFetchingMoreData(amount input: Int, type: Type) -> String {
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
        
        var url = basicUrl
        url.append(type.rawValue + "?")
        url.append("orderBy=" + orderBy)
        url.append("&limit=\(input)")
        url.append("&offset=\(skip+1)")
        url.append(authorisation)
        
        return url
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


