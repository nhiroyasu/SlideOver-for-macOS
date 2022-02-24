import Foundation

protocol URLEncodeService {
    func encode(text: String) -> String
}

class URLEncodeServiceImpl: URLEncodeService {
    func encode(text: String) -> String {
        let charset = CharacterSet.alphanumerics.union(.init(charactersIn: "/?-._~"))
        let decodeText = text.removingPercentEncoding
        return decodeText?.addingPercentEncoding(withAllowedCharacters: charset) ?? text
    }
}
