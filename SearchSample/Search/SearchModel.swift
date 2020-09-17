import Combine
import Foundation
import Kumo

protocol SearchService {
    func search(query: String) -> AnyPublisher<[Anime], Error>
}

class SearchModel: ObservableObject {
    @Published var animes = [Anime]()
    @Published var errorMessage = String?.none
    @Published var query = ""

    private var cancellables = [AnyCancellable]()

    init(_ service: SearchService) {
        _query.projectedValue
            .debounce(for: 0.3, scheduler: DispatchQueue.main) // Wait for the user to stop typing for 0.3 seconds before reacting.
            .map { [unowned self] in
                service.search(query: $0)
                    .catch { error -> AnyPublisher<[Anime], Never> in
                        // Don't propagate errors through the outer chain,
                        // let the outer chain have an error type of 'Never'.
                        self.errorMessage = "\(error.localizedDescription)"
                        return Empty().eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .switchToLatest() // Cancel any previously outbound requesst automatically!
            .sink(receiveValue: { [unowned self] animes in
                self.animes = animes
            })
            .store(in: &cancellables)
    }
}

extension String: Identifiable {
    public var id: String { self }
}
