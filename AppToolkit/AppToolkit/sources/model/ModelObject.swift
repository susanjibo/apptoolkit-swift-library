//
//  ModelObject.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 9/26/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

//MARK: base model object class

/**
 Base model class
 */
public class ModelObject: Mappable {
    /**Required initializer of the class*/
    required public init?(map: Map) { }

    /**Initializer of the class*/
    convenience public required init?() {
        let map = Map(mappingType: .fromJSON, JSON: [:])
        self.init(map: map)
    }
    
    /**Mapper of the class*/
    public func mapping(map: Map) { }
}

//MARK: protocol based variables serialization

/**
 Class to serialize an Object or a JSON.
 */
final class BasicProtocolTypeSerializationTransform<T: Mappable, P>: TransformType {
    /**Global object*/
    typealias Object = P
    /**Global JSON*/
    typealias JSON = [String: AnyObject]
    /**Initializer of the class*/
    init() {}
    
    /**Function to transform JSON to an Object*/
    public func transformFromJSON(_ value: Any?) -> P? {
        guard let json = value as? JSON else { return nil }
        
        return Mapper<T>().map(JSON: json) as? P
    }
    
    /**Function to transform an Object to JSON*/
    func transformToJSON(_ value: Object?) -> JSON? {
        guard let object = value as? BaseMappable else { return nil }
        
        return object.toJSON() as JSON
    }

}
