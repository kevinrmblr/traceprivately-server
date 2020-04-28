import Fluent
import Vapor

/// Controls basic CRUD operations on `Infected`s.
struct InfectedRestController {
    struct SubmitRequestDTO: Content {
        let keys: [String]
    }

    struct SubmitResponseDTO: Content {
        let status: ReponseStatusDTO
    }

    struct GetResponseDTO: Content {
        let status: ReponseStatusDTO
        let date: Date
        let keys: [String]
        let deletedKeys: [String]

        static func ok(keys: [String], deletedKeys: [String]) -> GetResponseDTO {
            return GetResponseDTO(status: .ok, date: Date(), keys: keys, deletedKeys: deletedKeys)
        }

        enum CodingKeys: String, CodingKey {
            case status, date, keys
            case deletedKeys = "deleted_keys"
        }
    }

    private let sinceFormatter: DateFormatter

    init() {
        sinceFormatter = DateFormatter()
    }

//    func get(_ req: Request) throws -> EventLoopFuture<GetResponseDTO> {
//        var newFuture: QueryBuilder<DailyTracingKey> = Infected.query(on: req.db)
//
//        guard let since: String = req.query["since"], let date = sinceFormatter.date(from: since) else {
//            return newFuture.all().map { list in GetResponseDTO.ok(keys: list.map { $0.key }, deletedKeys: []) }
//        }
//
//        let deletedFuture: QueryBuilder<DailyTracingKey> = Infected.query(on: req.db).withDeleted().filter(\.$deletedAt >= date)
//
//        newFuture = newFuture.filter(\.$createdAt >= date)
//        return newFuture.all().and(deletedFuture.all()).map { newList, deletedList in
//            GetResponseDTO.ok(keys: newList.map { $0.key },
//                              deletedKeys: deletedList.map { $0.key })
//        }
//    }
//
//    func post(_ req: Request) throws -> EventLoopFuture<SubmitResponseDTO> {
//        guard let dto: SubmitRequestDTO = try? req.content.decode(SubmitRequestDTO.self) else {
//            throw Abort(.badRequest)
//        }
//
//        return EventLoopFuture.andAllSucceed(dto.keys.map { DailyTracingKey(key: $0).save(on: req.db) },
//                                             on: req.eventLoop).map { _ in SubmitResponseDTO(status: .ok) }
//    }
//
//    func delete(_ req: Request) throws -> EventLoopFuture<SubmitResponseDTO> {
//        guard let dto: SubmitRequestDTO = try? req.content.decode(SubmitRequestDTO.self) else {
//            throw Abort(.badRequest)
//        }
//
//        return EventLoopFuture.andAllSucceed(dto.keys.map { DailyTracingKey.query(on: req.db).filter(\.$key == $0).delete() },
//                                             on: req.eventLoop).map { _ in SubmitResponseDTO(status: .ok) }
//    }
}
