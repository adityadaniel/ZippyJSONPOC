import Foundation
import ZippyJSON
import Combine

public enum ZippyJSONBenchmarkError: Error {
    case cannotReadJSON
    case cannotConvertToData
}

public func getJSONURL(fileName: String) -> URL? {
    guard let jsonURL = Bundle.module.url(forResource: fileName, withExtension: "json") else {
        return nil
    }
    return jsonURL
}

public struct ZippyJSONBenchmark {
    public static func decodeShopApple() {
        do {
            guard let jsonURL = getJSONURL(fileName: "ShopInfo") else {
                throw ZippyJSONBenchmarkError.cannotReadJSON
            }
            let data = try Data(contentsOf: jsonURL)
            _ = try appleAlternateDecoder.decode(HeaderAndShopInfoData.self, from: data)
        } catch {
            print(error)
        }
    }
    
    public static func decodeShopZippy() {
        do {
            guard let jsonURL = getJSONURL(fileName: "ShopInfo") else {
                throw ZippyJSONBenchmarkError.cannotReadJSON
            }
            let shopData = try Data(contentsOf: jsonURL)
            _ = try zippyDecoder.decode(HeaderAndShopInfoData.self, from: shopData)
        } catch {
            print(error)
        }
    }
    
    public static func decodePDPApple() {
        do {
            guard let jsonURL = getJSONURL(fileName: "PDPSecondPriority") else {
                throw ZippyJSONBenchmarkError.cannotReadJSON
            }
            let data = try Data(contentsOf: jsonURL)
            _ = try appleAlternateDecoder.decode(PDPSecondPriority.self, from: data)
        } catch {
            print(error)
        }
    }
    
    public static func decodePDPZippy() {
        do {
            guard let jsonURL = getJSONURL(fileName: "PDPSecondPriority") else {
                throw ZippyJSONBenchmarkError.cannotReadJSON
            }
            let shopData = try Data(contentsOf: jsonURL)
            _ = try zippyAlternateDecoder.decode(PDPSecondPriority.self, from: shopData)
        } catch {
            print(error)
        }
    }
}

public let appleDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    return decoder
}()

public let appleAlternateDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.context = AlternateDecodingContext(usingAlternateKeys: true)
    return decoder
}()

public let zippyDecoder: ZippyJSONDecoder = {
    let decoder = ZippyJSONDecoder()
    return decoder
}()

public let zippyAlternateDecoder: ZippyJSONDecoder = {
    let decoder = ZippyJSONDecoder()
    decoder.context = AlternateDecodingContext(usingAlternateKeys: true)
    return decoder
}()

extension JSONDecoder: TopLevelDecoder {}
extension ZippyJSONDecoder: TopLevelDecoder {}

private let contextKey = CodingUserInfoKey(rawValue: "alternateContext")!

extension ZippyJSONDecoder {
    public var context: AlternateDecodingContext? {
        get { return userInfo[contextKey] as? AlternateDecodingContext }
        set { userInfo[contextKey] = newValue }
    }
}
