//
//  DisplayCommand.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 12/4/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class DisplayView: ModelObject {
    var type: DisplayViewType
    var name: String

    required init?(map: Map) {
        self.type = .undefined
        self.name = ""
        
        super.init(map: map)
    }
    
    convenience init?(name: String) {
        let map = Map(mappingType: .fromJSON, JSON: [:])
        self.init(map: map)
        
        self.name = name
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        type <- map["Type"]
        name <- map["Name"]
    }
}

class EyeView: DisplayView {
    
    required init?(map: Map) {
        super.init(map: map)
        
        self.type = .eye
    }
}
//MARK: Display 
/** 
 Data object for image information
 */
public struct ImageData {
    /// Name of asset in local cache
    public var name: String
    /// URL to the image
    public var source: String
    /// unsupported
    public var set: String?
    /// :nodoc:
    public init(_ name: String, source: String, set: String? = nil) {
        self.name = name
        self.source = source
        self.set = set
    }
}

class DisplayImage: ModelObject {
    var name: String = ""
    var source: String? = nil
    var set: String? = nil

    convenience init?(_ image: ImageData) {
        let map = Map(mappingType: .fromJSON, JSON: [:])
        self.init(map: map)
        
        name = image.name
        set = image.set
        source = image.source
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
        
        name    <- map["name"]
        source  <- map["src"]
        set     <- map["set"]
    }
}

class ImageView: DisplayView {
    var image: DisplayImage? = nil

    required init?(map: Map) {
        super.init(map: map)
        
        self.type = .image
    }

    convenience init?(_ image: DisplayImage, name: String) {
        let map = Map(mappingType: .fromJSON, JSON: [:])
        self.init(map: map)
        
        self.image = image
        self.name = name
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
        
        image <- map["Image"]
    }
}

class TextView: DisplayView {
    var text: String = ""
    
    required init?(map: Map) {
        super.init(map: map)
        
        self.type = .text
    }

    convenience init?(_ text: String, name: String) {
        let map = Map(mappingType: .fromJSON, JSON: [:])
        self.init(map: map)
        
        self.text = text
        self.name = name
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
        
        text <- map["Text"]
    }
}

class DisplayCommand: Command {
    var view: DisplayView? = nil
    
    required init?(map: Map) {
        super.init(map: map)
        
        self.type = .display
    }
    
    convenience init?(_ view: DisplayView) {
        guard view.name.count > 0 else { return nil }
        
        let map = Map(mappingType: .fromJSON, JSON: [:])
        self.init(map: map)
        
        self.view = view
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        view <- map["View"]
    }

}
