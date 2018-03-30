//
//  NLUModels.swift
//  AppToolkit
//
//  Created by Justin Shiiba on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 * TODO: Listen Event is not supported yet. NLU Models may need to change.
 */

struct NLUEntity {
    let name: String
    let value: [String]
    static let `default` = NLUEntity(name: "", value: [])
}

struct NLUEntityTransformer: TransformType {
    typealias Object = NLUEntity
    typealias JSON = [String: Any]
    typealias SingleValue = String
    typealias MultipleValues = [String]

    func transformFromJSON(_ value: Any?) -> Object? {
        guard let entity = value as? JSON, let name = entity["Name"] as? String else {
            return nil
        }

        if let single = entity["Value"] as? SingleValue {
            return NLUEntity(name: name, value: [single])
        } else if let multiple = entity["Value"] as? MultipleValues {
            return NLUEntity(name: name, value: multiple)
        } else {
            return nil
        }
    }

    func transformToJSON(_ value: Object?) -> JSON? {
        assertionFailure("Not implemented")
        return nil
    }
}

struct NLUParse: Mappable {
    var confidence: Float
    var intent: String
    var entity: NLUEntity

    init?(map: Map) {
        confidence = 0
        intent = ""
        entity = NLUEntity.default
    }

    mutating func mapping(map: Map) {
        confidence <- map["Confidence"]
        intent     <- map["Intent"]
        entity     <- (map["Entity"], NLUEntityTransformer())
    }
}

struct NLUResult: Mappable {
    var agent: String
    var parse: [NLUParse]

    init?(map: Map) {
        agent = ""
        parse = []
    }

    mutating func mapping(map: Map) {
        agent <- map["Agent"]
        parse <- map["Parse"]
    }
}
