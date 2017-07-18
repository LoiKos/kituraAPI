//
//  JSON.swift
//  kituraMbao
//
//  Created by Loic LE PENN on 21/06/2017.
//
//
import SwiftyJSON
import Foundation

protocol JSONSerializable {
    func toJSON() throws -> String
}

extension String: JSONSerializable {
    public func toJSON() -> String {
        return "\"\(self)\""
    }
}

extension Int : JSONSerializable {
    public func toJSON() -> String {
        return "\(self)"
    }
}

extension Date : JSONSerializable {
    public func toJSON() -> String {
        return String(describing: self).toJSON()
    }
}

extension Int8 : JSONSerializable {
    public func toJSON() -> String {
        return "\(self)"
    }
}

extension Int16 : JSONSerializable {
    public func toJSON() -> String {
        return "\(self)"
    }
}

extension Int32 : JSONSerializable {
    public func toJSON() -> String {
        return "\(self)"
    }
}

extension Int64 : JSONSerializable {
    public func toJSON() -> String {
        return "\(self)"
    }
}

// the same as Float
extension Float32 : JSONSerializable {
    public func toJSON() -> String {
        return "\(self)"
    }
}

// the same as Double
extension Float64 : JSONSerializable {
    public func toJSON() -> String {
        return "\(self)"
    }
}

extension Float80 : JSONSerializable {
    public func toJSON() -> String {
        return "\(self)"
    }
}

extension Array : JSONSerializable {
    public func toJSON() throws -> String {
        var out = [String]()
        for item in self {
            if let item = item as? JSONSerializable {
               let serializeItem = try item.toJSON()
               out.append(serializeItem)
            } else {
                throw JSONSerializableError.typeUnSerializable
            }
        }
        return "[\(out.joined(separator: ", "))]"
    }
}

extension Dictionary : JSONSerializable {
    public func toJSON() throws -> String {
        var out = [String:JSONSerializable]()
        for k in self.keys {
            if let pv = self[k], let v = pv as? JSONSerializable {
                let k = String(describing: k)
                out[k] = try v.toJSON()
            } else {
                throw JSONSerializableError.typeUnSerializable
            }
        }
        let array = out.map({ (key,value) -> String in  return "\(key.toJSON()):\(value)"})
        return "{ \(array.joined(separator: ", ")) }"
    }
}

enum JSONSerializableError : Error {
    case typeUnSerializable
    case notConvertible
}

