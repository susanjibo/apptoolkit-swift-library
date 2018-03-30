//
//  MathModels.swift
//  AppToolkit
//
//  Created by Justin Shiiba on 10/5/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

// MARK: Math

/**
 2D vector. Default = `Vector2(x: 0, y: 0)`
 */
public struct Vector2 {
    /// horizontal
    public let x: Float
    /// vertical
    public let y: Float
	
	static let `default` = Vector2(x: 0, y: 0)
	/// :nodoc:
	public init(x: Float, y: Float) {
		self.x = x
		self.y = y
	}
}

/// :nodoc:
struct Vector2Transformer: TransformType {
	typealias Object = Vector2
	typealias JSON = [Float]
	
	func transformFromJSON(_ value: Any?) -> Vector2? {
        // Vector2 JSON always contains 2 elements in predefined order (x, y)
		guard let floats = value as? JSON, floats.count == 2 else { return nil }
		return Vector2(x: floats[0], y: floats[1])
	}
	
	func transformToJSON(_ value: Vector2?) -> [Float]? {
		guard let vector2 = value else { return nil }
		return [vector2.x, vector2.y]
	}
    
    static func transformToJSON(value: Vector2?) -> [Float]? {
        guard let vector2 = value else { return nil }
        return [vector2.x, vector2.y]
    }
}

/**
 3D vector
 */
public struct Vector3 {
    /// meters forward
    public let x: Float
    /// meters left
    public let y: Float
    /// meters up
    public let z: Float

    static let `default` = Vector3(x: 0, y: 0, z: 0)
	
    /// :nodoc:
	public init(x: Float, y: Float, z: Float) {
		self.x = x
		self.y = y
		self.z = z
	}
}

/// :nodoc:
extension Vector3: Equatable {
    public static func ==(lhs: Vector3, rhs: Vector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

/// :nodoc:
struct Vector3Transformer: TransformType {
    typealias Object = Vector3
    typealias JSON = [Float]

    func transformFromJSON(_ value: Any?) -> Vector3? {
        // Vector3 JSON always contains 3 elements in predefined order (x, y, z)
        guard let floats = value as? JSON, floats.count == 3 else { return nil }
        return Vector3(x: floats[0], y: floats[1], z: floats[2])
    }

    func transformToJSON(_ value: Vector3?) -> JSON? {
		guard let vector3 = value else { return nil }
		return [vector3.x, vector3.y, vector3.z]
    }
}

/**
  Default = `AngleVector(theta: 0, psi: 0)`
  These angles are relative to Jibo's current orientation.
 */
public struct AngleVector {
    /// Twist/horizontal angle
    public let theta: Float
    // Vertical angle
    public let psi: Float

    static let `default` = AngleVector(theta: 0, psi: 0)
	/// :nodoc:
	public init(theta: Float, psi: Float) {
		self.theta = theta
		self.psi = psi
	}
}
/// :nodoc:
extension AngleVector: Equatable {
    public static func ==(lhs: AngleVector, rhs: AngleVector) -> Bool {
        return lhs.theta == rhs.theta && lhs.psi == rhs.psi
    }
}
/// :nodoc:
struct AngleVectorTransformer: TransformType {
    typealias Object = AngleVector
    typealias JSON = [Float]

    func transformFromJSON(_ value: Any?) -> AngleVector? {
        guard let angles = value as? JSON, angles.count == 2 else { return nil }
        return AngleVector(theta: angles[0], psi: angles[1])
    }

    func transformToJSON(_ value: AngleVector?) -> JSON? {
		guard let angles = value else { return nil }
		return [angles.theta, angles.psi]
    }
}

/**
 Struct representing Jibo's screen.
 Default = `ScreenRectangle(x: 0, y: 0, width: 0, height: 0)`
 */
public struct ScreenRectangle {
    /// horizontal pixels, max: 1280
    public let x: Float
    /// vertical pixels, max: 720
    public let y: Float
    /// width in pixels, max: 1280
    public let width: Float
    /// height in pixels, max: 720
    public let height: Float

    static let `default` = ScreenRectangle(x: 0, y: 0, width: 0, height: 0)
}

/// :nodoc:
struct ScreenRectangleTransformer: TransformType {
    typealias Object = ScreenRectangle
    typealias JSON = [Float]

    func transformFromJSON(_ value: Any?) -> ScreenRectangle? {
        // ScreenRectangle JSON always contains 4 elements in predefined order (x, y, width, height)
        guard let values = value as? JSON, values.count == 4 else { return nil }
        return ScreenRectangle(x: values[0], y: values[1], width: values[2], height: values[3])
    }

    func transformToJSON(_ value: ScreenRectangle?) -> JSON? {
        guard let value = value else { return nil }

        return [value.x, value.y, value.width, value.height]
    }
}

/// :nodoc:
extension ScreenRectangle: Equatable {
    public static func ==(lhs: ScreenRectangle, rhs: ScreenRectangle) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.width == rhs.width && lhs.height == rhs.height
    }
}
