//
//  DataManager.swift
//  RSS-Reader
//
//  Created by  Oleksandra on 1/16/19.
//  Copyright © 2019 sandra-alt. All rights reserved.
//

import Foundation

fileprivate enum XMLTag: String {
    case title = "title"
    case description = "description"
    case link = "link"
    case pubDate = "pubDate"
    case category = "category"
    case creator = "dc:creator"
    case publisher = "dc:publisher"
    case imageURL = "media:thumbnail"
}

fileprivate enum ParentXMLTag: String {
    case item = "item"
    case channel = "channel"
}

class DataManager : NSObject, XMLParserDelegate {
    fileprivate var xmlParser: XMLParser!
    fileprivate var currentTag: XMLTag!
    fileprivate var currentCharacters = ""
    
    fileprivate var currentEntry = Entry()
    fileprivate var entries = [Entry]()
    fileprivate var parentTag = ParentXMLTag.channel

    func parseXMLWithURL(_ url :URL) -> [Entry] {
        xmlParser = XMLParser(contentsOf: url)!
        xmlParser.delegate = self
        xmlParser.parse()
        return entries
    }

    //MARK: - XMLParserDelegate methods
    
    internal func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {        
        if let tag = ParentXMLTag(rawValue: elementName) {
            parentTag = tag
        } else if let tag = XMLTag(rawValue: elementName) {
            currentTag = tag
            if currentTag == .imageURL {
                if let urlString = attributeDict["url"] {
                    currentEntry.imageURL = URL(string:urlString)
                }
            }
        }
        
    }
    
    internal func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !string.isEmpty && parentTag == .item {
            currentCharacters.append(string)
        }
    }
    
    internal func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if ParentXMLTag(rawValue: elementName) == .item {
            entries.append(currentEntry)
            currentEntry = Entry()
        } else if parentTag == .item {
            switch currentTag {
            case .title:
                currentEntry.title = currentCharacters
            case .description:
                currentEntry.description = currentCharacters
            case .link:
                if currentEntry.link == nil {
                    currentEntry.link = URL(string:currentCharacters)
                }
            case .pubDate:
                if currentEntry.pubDate == nil {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
                    let date = formatter.date(from:currentCharacters)!
                    currentEntry.pubDate = date
                }
            case .category:
                if currentEntry.category == nil {
                    currentEntry.category = currentCharacters
                }
            case .creator:
                if currentEntry.creator == nil {
                    currentEntry.creator = currentCharacters
                }
            case .publisher:
                if currentEntry.publisher == nil {
                    currentEntry.publisher = currentCharacters
                }
            default:
                break
            }
            currentCharacters = ""
        }
    }

}
