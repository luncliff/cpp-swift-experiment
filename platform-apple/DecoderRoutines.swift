import Foundation

class DecoderRoutines {
  var jsd: JSONDecoder = .init()

  @objc
  init() {
    jsd.keyDecodingStrategy = .useDefaultKeys
    if #available(macOS 12.0, *) {
      jsd.allowsJSON5 = true
    }
  }

  @objc
  func print2() {
    let text = """
    { "name": "swift" }
    """
    do {
      try print2(text: text)
    } catch {
      print(error)
    }
  }

  @objc
  func print2(text: String) throws {
    struct Result: Codable {
      var name: String
      var points: Int?
    }
    let result = try jsd.decode(Result.self, from: text.data(using: .utf8)!)
    print(result.name)
  }
}
