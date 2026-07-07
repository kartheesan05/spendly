import Foundation

struct NotionQueryResponse: Decodable {
    let results: [NotionPage]
    let hasMore: Bool
    let nextCursor: String?

    enum CodingKeys: String, CodingKey {
        case results
        case hasMore = "has_more"
        case nextCursor = "next_cursor"
    }
}

struct NotionPage: Decodable {
    let id: String
    let properties: NotionProperties

    func toSpend() -> Spend? {
        guard let amount = properties.amount.number, amount > 0 else { return nil }
        guard let dateString = properties.date.date?.start, let date = Spend.dateFormatter.date(from: dateString) else { return nil }
        let name = properties.name.title.first?.plainText ?? "Untitled"
        let category = properties.category.select?.name ?? "Other"
        let payment = properties.paymentMethod.select?.name ?? "Unknown"
        return Spend(
            id: id,
            name: name,
            amount: amount,
            category: category,
            paymentMethod: payment,
            date: date
        )
    }
}

struct NotionProperties: Decodable {
    let name: TitleProperty
    let amount: NumberProperty
    let date: DateProperty
    let paymentMethod: SelectProperty
    let category: SelectProperty

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case amount = "Amount"
        case date = "Date"
        case paymentMethod = "Payment Method"
        case category = "Category"
    }
}

struct TitleProperty: Decodable {
    let title: [TitleText]
}

struct TitleText: Decodable {
    let plainText: String
    enum CodingKeys: String, CodingKey {
        case plainText = "plain_text"
    }
}

struct NumberProperty: Decodable {
    let number: Double?
}

struct DateProperty: Decodable {
    let date: DateValue?
}

struct DateValue: Decodable {
    let start: String
}

struct SelectProperty: Decodable {
    let select: SelectValue?
}

struct SelectValue: Decodable {
    let name: String
}
