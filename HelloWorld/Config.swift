import Foundation

enum Config {
    static let notionToken = (Bundle.main.object(forInfoDictionaryKey: "NOTION_TOKEN") as? String) ?? ""
    static let notionDatabaseID = (Bundle.main.object(forInfoDictionaryKey: "NOTION_DATABASE_ID") as? String) ?? ""
    static let notionVersion = "2022-06-28"
}
