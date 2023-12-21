import Foundation

struct CardModel: Codable {
    struct Card: Codable {
        let name: String
        let manaCost: String
        let type: String
        let setName: String
        let additionalProperties: [String: String]?
        
        enum CodingKeys: String, CodingKey {
            case name, manaCost, type, setName
            case additionalProperties = "другое"
        }
    }
    
    let cards: [Card]
}

enum ErrorWeb: Error {
    case URLFailure, invalidData
}

enum OurCards: String {
    case opt = "Opt"
    case blackLotus = "Black%20Lotus"
}

class WebService {
    static let shared = WebService()
    private init() { }
    
    private func getURL(cardName: OurCards) -> URL? {
        let baseURL = "https://"
        let apiDomain = "api.magicthegathering.io/v1/"
        let cardsEndpoint = "cards"
        let urlString = "\(baseURL)\(apiDomain)\(cardsEndpoint)?name=\(cardName.rawValue)"
        return URL(string: urlString)
    }
    
    func fetchData(cardName: OurCards, completion: @escaping(Result<CardModel, Swift.Error>) ->()) {
        guard let url = getURL(cardName: cardName) else {
            return completion(.failure(ErrorWeb.URLFailure))
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return completion(.failure(error ?? ErrorWeb.invalidData))
            }
            do {
                let cardData = try JSONDecoder().decode(CardModel.self, from: data)
                completion(.success(cardData))
            } catch {
                completion(.failure(ErrorWeb.invalidData))
            }
        }.resume()
    }
}

func printCardInfo(cardName: OurCards) {
    WebService.shared.fetchData(cardName: cardName) { result in
        if case .success(let cards) = result, let card = cards.cards.first {
            print("Имя карты: \(card.name)")
            print("Тип: \(card.type)")
            print("Мановая стоимость: \(card.manaCost)")
            print("Название сета: \(card.setName)")
            
            if let additionalProperties = card.additionalProperties {
                print("\nAdditional Properties:")
                additionalProperties.forEach { print("\($0): \($1)") }
            }
        } else if case .failure(let error) = result {
            print("Ошибка: \(error.localizedDescription)")
        } else {
            print("Карта не найдена.")
        }
    }
}

printCardInfo(cardName: OurCards.blackLotus)
