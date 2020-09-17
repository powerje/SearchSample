import Combine
import Foundation
import Kumo

struct JikanSearchService: SearchService {
    let service = Service(baseURL: URL(string: "https://api.jikan.moe/v3")!)
    func search(query: String) -> AnyPublisher<[Anime], Error> {
        if query.isEmpty {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return service.perform(HTTP.Request.get("search/anime")
            .parameters(["q": query])
            .keyed(under: "results"))
    }
}

struct Anime: Decodable, Hashable {
    let airing: Bool
    let malId: Int
    let url: String
    let imageURL: String
    let title: String
    let synopsis: String
    let rated: String?

    enum CodingKeys: String, CodingKey {
        case airing
        case malId = "mal_id"
        case url
        case imageURL = "image_url"
        case title
        case synopsis
        case rated
    }
}

extension Anime: Identifiable {
    var id: Int { malId }
}
