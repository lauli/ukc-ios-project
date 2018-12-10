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
    
    func requestCharacter(forId id: Int, atIndex index: Int, completion: @escaping Success) {
        
        var url = "https://gateway.marvel.com:443/v1/public/characters?"
        url.append("&id=\(id)")
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
