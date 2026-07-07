import Foundation

struct NotionService {
    var token: String { Config.notionToken }
    var databaseID: String { Config.notionDatabaseID }

    func fetchSpends() async throws -> [Spend] {
        var allSpends: [Spend] = []
        var cursor: String? = nil
        let decoder = JSONDecoder()

        repeat {
            var body: [String: Any] = ["page_size": 100]
            if let cursor { body["start_cursor"] = cursor }

            var request = URLRequest(
                url: URL(string: "https://api.notion.com/v1/databases/\(databaseID)/query")!
            )
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue(Config.notionVersion, forHTTPHeaderField: "Notion-Version")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Notion API error \(http.statusCode): \(message)"])
            }

            let page = try decoder.decode(NotionQueryResponse.self, from: data)
            allSpends.append(contentsOf: page.results.compactMap { $0.toSpend() })

            cursor = page.hasMore ? page.nextCursor : nil
        } while cursor != nil

        return allSpends.sorted { $0.date > $1.date }
    }
}
