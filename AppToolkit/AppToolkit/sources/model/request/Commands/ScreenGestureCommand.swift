//
//  ScreenGestureCommand.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 12/14/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import ObjectMapper

//MARK: - Screen
/// Type of screen gesture Jibo received
public enum ScreenGestureType: String {
    case tap = "Tap"
    case swipeDown = "SwipeDown"
    case swipeUp = "SwipeUp"
    case swipeRight = "SwipeRight"
    case swipeLeft = "SwipeLeft"
}

/// Direction of the swipe Jibo received
public enum ScreenGestureSwipeDirection: String {
    case up = "Up"
    case down = "Down"
    case right = "Right"
    case left = "Left"
}

//MARK: Screen Gesture
/** 
 Parameters for listening for a screen gesture
 */
public struct ScreenGestureListenParams {
    /** 
     Can be either a tap or a swipe of a certain direction.
     */
    public var type: ScreenGestureType
    /**
     Area of the screen in which to listen for a gesture. 
     Can be a circular or rectangular area.
     */
    public var area: Area
    
    /// :nodoc:
    public init(type: ScreenGestureType, area: Area) {
        self.type = type
        self.area = area
    }
}

// MARK: - Area
/// See `Rectangle` and `Circle`
public protocol Area { }

/// :nodoc:
struct AreaTransformer: TransformType {
    typealias Object = Area
    typealias JSON = [String: Any]
    
    func transformFromJSON(_ value: Any?) -> Area? {
        let result: Any? = RectangleTransformer.transformFromJSON(value) ?? CircleTransformer.transformFromJSON(value)
        return result as? Area
    }
    
    func transformToJSON(_ value: Area?) -> JSON? {
        guard let value = value else { return nil }
        
        if let rect = value as? Rectangle {
            return RectangleTransformer.transformToJSON(rect)
        } else if let circle = value as? Circle {
            return CircleTransformer.transformToJSON(circle)
        } else {
            return nil
        }
    }
}
/**
 Defines a rectangle on Jibo's screen. 

 `default` = Rectangle(x: 0, y: 0, width: 0, height: 0)
 - Parameters:
    - x: horizontal coordinate of upper-left corner. `(0,1280)`
    - y: vertical coordinate of upper-left corner. `(0,720)`
    - width: pixels wide `(0,1280)`
    - height: pixels high `(0,720)`
 */
public struct Rectangle: Area {
    let x: Float
    let y: Float
    let width: Float
    let height: Float
    static let `default` = Rectangle(x: 0, y: 0, width: 0, height: 0)
    /// :nodoc:
    public init(x: Float, y: Float, width: Float, height: Float) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}
/// :nodoc:
struct RectangleTransformer: TransformType {
    typealias Object = Rectangle
    typealias JSON = [String: Any]
    
    func transformFromJSON(_ value: Any?) -> Rectangle? {
        return RectangleTransformer.transformFromJSON(value)
    }
    
    func transformToJSON(_ value: Rectangle?) -> [String : Any]? {
        return RectangleTransformer.transformToJSON(value)
    }
    
    fileprivate static func transformFromJSON(_ value: Any?) -> Rectangle? {
        guard let values = value as? JSON,
            let x = values["x"] as? Float,
            let y = values["y"] as? Float,
            let width = values["width"] as? Float,
            let height = values["height"] as? Float
            else { return nil }
        return Rectangle(x: x, y: y, width: width, height: height)
    }
    
    fileprivate static func transformToJSON(_ value: Rectangle?) -> JSON? {
        guard let rect = value else { return nil }
        
        return ["x": rect.x, "y": rect.y, "width": rect.width, "height": rect.height]
    }
}
/// :nodoc:
extension Rectangle: Equatable {
    public static func ==(lhs: Rectangle, rhs: Rectangle) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.width == rhs.width && lhs.height == rhs.height
    }
}
/**
 Defines a circular area on Jibo's screen.

 `default = Circle(x: 0, y: 0, radius: 0)`
 - Parameters:
    - x: horizontal coordinate of circle's center `(0,1280)`
    - y: vertical coordinate of circle's center `(0,720)`
    - radius: `(0,360)`
 */ 
public struct Circle: Area {
    let x: Float
    let y: Float
    let radius: Float
    static let `default` = Circle(x: 0, y: 0, radius: 0)
    /// :nodoc:
    public init(x: Float, y: Float, radius: Float) {
        self.x = x
        self.y = y
        self.radius = radius
    }
}
/// :nodoc:
struct CircleTransformer: TransformType {
    typealias Object = Circle
    typealias JSON = [String: Any]
    
    func transformFromJSON(_ value: Any?) -> Circle? {
        return CircleTransformer.transformFromJSON(value)
    }
    
    func transformToJSON(_ value: Circle?) -> JSON? {
        return CircleTransformer.transformToJSON(value)
    }
    
    fileprivate static func transformFromJSON(_ value: Any?) -> Circle? {
        guard let values = value as? JSON,
                let x = values["x"] as? Float,
                let y = values["y"] as? Float,
                let radius = values["radius"] as? Float
                else { return nil }
        
        return Circle(x: x, y: y, radius: radius)
    }
    
    fileprivate static func transformToJSON(_ value: Circle?) -> JSON? {
        guard let circle = value else { return nil }
        
        return ["x": circle.x, "y": circle.y, "radius": circle.radius]
    }
}
/// :nodoc:
extension Circle: Equatable {
    public static func ==(lhs: Circle, rhs: Circle) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.radius == rhs.radius
    }
}

// MARK: - Filter
/// :nodoc:
class ScreenGestureFilter: BaseStreamFilter {
    var type: ScreenGestureType?
    var area: Area?
    
    convenience init?(_ params: ScreenGestureListenParams) {
        self.init(map: Map(mappingType: .fromJSON, JSON: [:]))

        self.type = params.type
        self.area = params.area
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        type <- (map["Type"], EnumTransform<ScreenGestureType>())
        area <- (map["Area"], AreaTransformer())
    }

}
