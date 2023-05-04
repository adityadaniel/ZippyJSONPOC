import Foundation

public enum CustomConvertibleError: Error {
    case notFound
    case failedConvert
}

public protocol CustomConvertible {
    func convert<Result>(to type: Result.Type) throws -> Result
    func convert(to type: Bool.Type) throws -> Bool
    func convert(to type: Int.Type) throws -> Int
    func convert(to type: String.Type) throws -> String
    func convert(to type: Date?.Type) throws -> Date?
}

extension CustomConvertible {
    public func convert<Result>(to type: Result.Type) throws -> Result {
        if type == Bool.self {
            return try convert(to: Bool.self) as! Result
        }

        if type == Int.self {
            return try convert(to: Int.self) as! Result
        }

        if type == String.self {
            return try convert(to: String.self) as! Result
        }

        if type == Date?.self {
            return try convert(to: Date?.self) as! Result
        }

        throw CustomConvertibleError.notFound
    }
}

extension Int: CustomConvertible {
    public func convert(to _: Bool.Type) throws -> Bool {
        self == 1
    }

    public func convert(to _: Int.Type) throws -> Int {
        self
    }

    public func convert(to _: String.Type) throws -> String {
        String(self)
    }

    public func convert(to _: Date?.Type) throws -> Date? {
        nil
    }
}
