import Fluent
import Leaf
import Vapor

struct InfectedWebController {
    private struct BatchItem: Codable {
        let key: String
        let keys: String
        let createdAt: Date?
        let status: String
    }

    func index(_ req: Request) throws -> EventLoopFuture<View> {
        TracingKeyBatch.query(on: req.db).sort(\.$createdAt).with(\.$keys).all().flatMap { items in
            struct Context: Codable {
                var items: [BatchItem]
            }
            let items = items.map { batch in
                BatchItem(key: batch.key.uuidString,
                          keys: batch.keys.reduce("") { "\($0), \($1.key.base64EncodedString())" },
                          createdAt: batch.createdAt,
                          status: batch.status.rawValue)
            }
            let context = Context(items: items)

            return req.view.render("index", context)
        }
    }
}
