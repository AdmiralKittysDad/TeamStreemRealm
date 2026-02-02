import Foundation

// MARK: - Generic Airtable Record
struct AirtableRecord: Codable {
    let id: String
    let fields: [String: Any]
    let createdTime: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fields
        case createdTime
    }

    init(id: String, fields: [String: Any], createdTime: String? = nil) {
        self.id = id
        self.fields = fields
        self.createdTime = createdTime
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        createdTime = try container.decodeIfPresent(String.self, forKey: .createdTime)

        // Decode fields as [String: Any]
        let fieldsContainer = try container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .fields)
        var fieldsDict: [String: Any] = [:]

        for key in fieldsContainer.allKeys {
            if let intValue = try? fieldsContainer.decode(Int.self, forKey: key) {
                fieldsDict[key.stringValue] = intValue
            } else if let doubleValue = try? fieldsContainer.decode(Double.self, forKey: key) {
                fieldsDict[key.stringValue] = doubleValue
            } else if let boolValue = try? fieldsContainer.decode(Bool.self, forKey: key) {
                fieldsDict[key.stringValue] = boolValue
            } else if let stringValue = try? fieldsContainer.decode(String.self, forKey: key) {
                fieldsDict[key.stringValue] = stringValue
            } else if let arrayValue = try? fieldsContainer.decode([String].self, forKey: key) {
                fieldsDict[key.stringValue] = arrayValue
            } else if let arrayValue = try? fieldsContainer.decode([[String: AnyCodable]].self, forKey: key) {
                fieldsDict[key.stringValue] = arrayValue.map { $0.mapValues { $0.value } }
            }
        }

        fields = fieldsDict
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(createdTime, forKey: .createdTime)

        var fieldsContainer = container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .fields)
        for (key, value) in fields {
            let codingKey = DynamicCodingKey(stringValue: key)!
            if let intValue = value as? Int {
                try fieldsContainer.encode(intValue, forKey: codingKey)
            } else if let doubleValue = value as? Double {
                try fieldsContainer.encode(doubleValue, forKey: codingKey)
            } else if let boolValue = value as? Bool {
                try fieldsContainer.encode(boolValue, forKey: codingKey)
            } else if let stringValue = value as? String {
                try fieldsContainer.encode(stringValue, forKey: codingKey)
            } else if let arrayValue = value as? [String] {
                try fieldsContainer.encode(arrayValue, forKey: codingKey)
            }
        }
    }
}

// MARK: - Airtable Response
struct AirtableResponse: Codable {
    let records: [AirtableRecord]
    let offset: String?
}

// MARK: - Airtable Create/Update Request
struct AirtableCreateRequest: Codable {
    let fields: [String: AnyCodable]

    init(fields: [String: Any]) {
        self.fields = fields.mapValues { AnyCodable($0) }
    }
}

struct AirtableBatchRequest: Codable {
    let records: [AirtableRecordRequest]
}

struct AirtableRecordRequest: Codable {
    let id: String?
    let fields: [String: AnyCodable]

    init(id: String? = nil, fields: [String: Any]) {
        self.id = id
        self.fields = fields.mapValues { AnyCodable($0) }
    }
}

// MARK: - Dynamic Coding Key
struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

// MARK: - AnyCodable Wrapper
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            value = dictValue.mapValues { $0.value }
        } else {
            value = ""
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let arrayValue = value as? [Any] {
            try container.encode(arrayValue.map { AnyCodable($0) })
        } else if let dictValue = value as? [String: Any] {
            try container.encode(dictValue.mapValues { AnyCodable($0) })
        }
    }
}
