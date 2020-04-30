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
        return Self.details(for: keyUUID, on: req.db)
            .flatMap { batch in
                let details = BatchDetails(key: batch.key.uuidString,
                                           keyCount: batch.keys.count,
                                           createdAt: batch.createdAt!.description,
                                           status: batch.status,
                                           formFields: batch.formFields.map { BatchDetails.FormField(key: $0.key, value: $0.value) })

                return req.view.render("batch", details)
            }
    }

    func confirm(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let key = req.parameters.get("key"), let keyUUID = UUID(uuidString: key) else {
            throw Abort(.notFound)
        }

        return Self.details(for: keyUUID, on: req.db)
            .flatMap { batch in
                batch.status = .confirmed
                return batch.save(on: req.db).map { req.redirect(to: "/batch/\(key)") }
            }
    }

    func reject(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let key = req.parameters.get("key"), let keyUUID = UUID(uuidString: key) else {
            throw Abort(.notFound)
        }

        return Self.details(for: keyUUID, on: req.db)
            .flatMap { batch in
                batch.status = .rejected
                return batch.save(on: req.db).map { req.redirect(to: "/batch/\(key)") }
        }
    }

    private static func details(for id: UUID, on db: Database) -> EventLoopFuture<TracingKeyBatch> {
        TracingKeyBatch.query(on: db)
            .filter(\.$key == id)
            .with(\.$formFields)
            .with(\.$keys)
            .first()
            .unwrap(or: Abort(.notFound))
    }
}
