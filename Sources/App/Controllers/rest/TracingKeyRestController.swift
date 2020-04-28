import Fluent
import Vapor

struct TracingKeyRestController {
    struct SubmitRequestDTO: Content {
        let keys: [Data]
        let identifier: UUID?
    }

    struct SubmitResponseDTO: Content {
        let status: ReponseStatusDTO
    }

    struct GetResponseDTO: Content {
        let status: ReponseStatusDTO
        let date: Date
        let keys: [Data]
        let deletedKeys: [Data]

        static func ok(keys: [Data], deletedKeys: [Data]) -> GetResponseDTO {
            return GetResponseDTO(status: .ok, date: Date(), keys: keys, deletedKeys: deletedKeys)
        }

        enum CodingKeys: String, CodingKey {
            case status, date, keys
            case deletedKeys = "deleted_keys"
        }
    }

    private let sinceFormatter: ISO8601DateFormatter

    init() {
        sinceFormatter = ISO8601DateFormatter()
    }

    func get(_ req: Request) throws -> EventLoopFuture<GetResponseDTO> {
        var newFuture: QueryBuilder<TracingKey> = TracingKey.query(on: req.db)

        guard let since: String = req.query["since"], let date = sinceFormatter.date(from: since) else {
            return newFuture.all().map { list in GetResponseDTO.ok(keys: list.map { $0.key },
                                                                   deletedKeys: []) }
        }

        let deletedFuture: QueryBuilder<TracingKey> = TracingKey.query(on: req.db).withDeleted().filter(\.$deletedAt >= date)

        newFuture = newFuture.filter(\.$createdAt >= date)
        return newFuture.all().and(deletedFuture.all()).map { newList, deletedList in
            GetResponseDTO.ok(keys: newList.map { $0.key },
                              deletedKeys: deletedList.map { $0.key })
        }
    }

    func post(_ req: Request) throws -> EventLoopFuture<SubmitResponseDTO> {
        guard let dto: SubmitRequestDTO = try? req.content.decode(SubmitRequestDTO.self) else {
            throw Abort(.badRequest)
        }
        guard let device: Device = req.auth.get() else {
            throw Abort(.unauthorized)
        }

        return req.db.transaction { database -> EventLoopFuture<SubmitResponseDTO> in
            let batch: EventLoopFuture<TracingKeyBatch> = Self.createOrUpdate(db: database,
                                                                              batchId: dto.identifier,
                                                                              deviceId: device.id!)

            return batch.flatMap { batch in
                EventLoopFuture.andAllSucceed(dto.keys.compactMap {
                    TracingKey(batchId: batch.id!,
                               key: $0).save(on: database)
                }, on: req.eventLoop).map { _ in
                    SubmitResponseDTO(status: .ok)
                }
            }
        }
    }

    private static func createOrUpdate(db: Database, batchId: UUID?, deviceId: UUID) -> EventLoopFuture<TracingKeyBatch> {
        guard let batchId = batchId else {
            let newBatch = TracingKeyBatch(deviceId: deviceId)
            return newBatch.save(on: db).map { newBatch }
        }

        return TracingKeyBatch.query(on: db)
            .filter(\.$device.$id == deviceId)
            .filter(\.$key == batchId)
            .first().flatMap { existing in
                if let existing = existing {
                    return existing.save(on: db).map { existing }
                }
                let newBatch = TracingKeyBatch(deviceId: deviceId)
                return newBatch.save(on: db).map { newBatch }
        }
    }

    private static func createTracingKey() {}
}
