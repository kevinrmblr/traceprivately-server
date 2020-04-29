import Fluent
import Vapor

struct TracingKeyRestController {
    private let sinceFormatter: ISO8601DateFormatter

    init() {
        sinceFormatter = ISO8601DateFormatter()
    }

    func get(_ req: Request) throws -> EventLoopFuture<GetResponseDTO> {
        var newFuture: QueryBuilder<DailyTracingKey> = DailyTracingKey.query(on: req.db)
            .join(TracingKeyBatch.self, on: \DailyTracingKey.$batch.$id == \TracingKeyBatch.$id)
            .filter(TracingKeyBatch.self, \.$status == BatchStatus.confirmed)

        guard let since: String = req.query["since"], let date = sinceFormatter.date(from: since) else {
            return newFuture.all().map { list in GetResponseDTO.ok(keys: list.map { DailyTracingKeyDTO(key: $0.key,
                                                                                                       dayNumber: $0.dayNumber) }) }
        }

        let deletedFuture: QueryBuilder<DailyTracingKey> = DailyTracingKey.query(on: req.db).withDeleted().filter(\.$deletedAt >= date)

        newFuture = newFuture.filter(\.$createdAt >= date)
        return newFuture.all().and(deletedFuture.all()).map { newList, deletedList in
            GetResponseDTO.ok(keys: newList.map { DailyTracingKeyDTO(key: $0.key, dayNumber: $0.dayNumber) },
                              deletedKeys: deletedList.map { DailyTracingKeyDTO(key: $0.key, dayNumber: $0.dayNumber) })
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
                let dailyKeys = dto.keys.compactMap {
                    DailyTracingKey(batchId: batch.id!,
                                    key: $0.key,
                                    dayNumber: $0.dayNumber).save(on: database)
                }
                let formFields = dto.form?.compactMap {
                    TrackingKeyBatchFormField(batchId: batch.id!, type: .text, key: $0.key, value: $0.value).save(on: database)
                } ?? []
                return EventLoopFuture.andAllSucceed(dailyKeys + formFields, on: req.eventLoop).map { _ in
                    SubmitResponseDTO(status: .ok, identifier: batch.key)
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
                    return TrackingKeyBatchFormField.query(on: db).filter(\.$batch.$id == existing.id!).delete().map { existing }
                }
                let newBatch = TracingKeyBatch(deviceId: deviceId)
                return newBatch.save(on: db).map { newBatch }
            }
    }
}

extension TracingKeyRestController {
    struct SubmitRequestDTO: Content {
        let keys: [DailyTracingKeyDTO]
        let identifier: UUID?
        let form: [FormFieldDTO]?
    }

    struct SubmitResponseDTO: DynamicContent {
        let status: ReponseStatusDTO
        let identifier: UUID
    }

    struct GetResponseDTO: DynamicContent {
        let status: ReponseStatusDTO
        let date: Date
        let keys: [DailyTracingKeyDTO]
        let deletedKeys: [DailyTracingKeyDTO]

        static func ok(keys: [DailyTracingKeyDTO], deletedKeys: [DailyTracingKeyDTO] = []) -> GetResponseDTO {
            return GetResponseDTO(status: .ok, date: Date(), keys: keys, deletedKeys: deletedKeys)
        }

        enum CodingKeys: String, CodingKey {
            case status, date, keys
            case deletedKeys = "deleted_keys"
        }
    }

    struct DailyTracingKeyDTO: Content {
        let key: Data
        let dayNumber: Int

        enum CodingKeys: String, CodingKey {
            case key = "d"
            case dayNumber = "r"
        }
    }

    struct FormFieldDTO: Content {
        let key: String
        let type: String
        let value: String

        enum CodingKeys: String, CodingKey {
            case key = "name"
            case type
            case value = "str"
        }
    }
}

protocol DynamicContent: Content {}

extension DynamicContent {
    static func isValid(_ type: HTTPMediaTypePreference) -> Bool {
        guard type.mediaType.type != "*", type.mediaType.subType != "*" else { return false }
        switch type.mediaType {
        case .json, .msgPack: return true
        default: return false
        }
    }

    func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        let response = Response()
        do {
            let firstValid = request.headers.accept.first(where: Self.isValid)
            if let acceptedType = firstValid?.mediaType {
                try response.content.encode(self, as: acceptedType)
            } else {
                try response.content.encode(self)
            }
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
        return request.eventLoop.makeSucceededFuture(response)
    }
}


//.join(ParentModel.self, on: \ChildModel.$parent.$id == \ParentModel.$id)
//.filter(\.parent.$field == "Value")
