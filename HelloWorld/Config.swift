import Foundation

enum Config {
    static let notionToken = (Bundle.main.object(forInfoDictionaryKey: "NOTION_TOKEN") as? String) ?? ""
    static let notionDatabaseID = ""
    static let notionVersion = "2022-06-28"
}
