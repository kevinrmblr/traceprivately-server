import Fluent
import Leaf
import Vapor

struct TracingKeyBatchesWebController {
    private struct BatchItem: Codable {
        let key: String
        let keyCount: Int
        let createdAt: String
        let status: BatchStatus
    }

    private struct BatchDetails: Codable {
        let key: String
        let keyCount: Int
        let createdAt: String
        let status: BatchStatus
        let formFields: [FormField]

        struct FormField: Codable {
            let key, value: String
        }
    }

    func index(_ req: Request) throws -> EventLoopFuture<View> {
        TracingKeyBatch.query(on: req.db)
            .sort(\.$createdAt)
            .with(\.$keys)
            .all()
            .flatMap { items in

                struct Context: Codable {
                    var items: [BatchItem]
                }
                let items = items.map { batch in
                    BatchItem(key: batch.key.uuidString,
                              keyCount: batch.keys.count,
                              createdAt: batch.createdAt!.description,
                              status: batch.status)
                }
                let context = Context(items: items)

                return req.view.render("index", context)
            }
    }

    func batchDetails(_ req: Request) throws -> EventLoopFuture<View> {
        guard let key = req.parameters.get("key"), let keyUUID = UUID(uuidString: key) else {
            throw Abort(.notFound)
        }
        return TracingKeyBatch.query(on: req.db)
            .filter(\.$key == keyUUID)
            .with(\.$formFields)
            .with(\.$keys)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { batch in
                let details = BatchDetails(key: batch.key.uuidString,
                                           keyCount: batch.keys.count,
                                           createdAt: batch.createdAt!.description,
                                           status: batch.status,
                                           formFields: batch.formFields.map { BatchDetails.FormField(key: $0.key, value: $0.value) })


                return req.view.render("batch", details)
            }
    }
}
