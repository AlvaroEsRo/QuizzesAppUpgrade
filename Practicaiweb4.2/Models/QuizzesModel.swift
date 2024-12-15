import Foundation

class QuizzesModel: ObservableObject {
    // Los datos
    @Published var quizzes = [QuizItem]()
    @Published var score: Int = 0
    private let recordKey = "TotalAciertos" // Clave para el total de aciertos
    private let acertadosKey = "QuizzesAcertados"
   

    private let quizzesURL = "https://quiz.dit.upm.es/api/quizzes/random10"
    private let token = "31672ec34248438c2a53" // Sustituir con el token proporcionado
    

    func loadQuizzesFromServer() {
        guard let url = URL(string: "\(quizzesURL)?token=\(token)") else {
            print("URL no válida")
            return
        }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error al descargar quizzes: \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    print("Error: No se recibieron datos")
                }
                return
            }

            do {
                let quizzes = try JSONDecoder().decode([QuizItem].self, from: data)
                DispatchQueue.main.async {
                    self?.quizzes = quizzes
                    self?.score = 0 // Reinicia el contador de aciertos
                    print("Quizzes descargados correctamente")
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error al decodificar los datos: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
        
    var totalAcertadosRecord: Int {
          get {
              return UserDefaults.standard.integer(forKey: recordKey)
          }
          set {
              UserDefaults.standard.set(newValue, forKey: recordKey)
          }
      }
      
      // Marca un quiz como acertado y actualiza el récord persistente
      func markQuizAsCorrect(id: Int) {
          // Recupera el conjunto de IDs acertados
          var acertadosSet = Set(UserDefaults.standard.array(forKey: acertadosKey) as? [Int] ?? [])
          
          // Si el ID no estaba ya en el conjunto, añádelo y actualiza el total
          if acertadosSet.insert(id).inserted {
              totalAcertadosRecord += 1 // Incrementa el contador total
              UserDefaults.standard.set(Array(acertadosSet), forKey: acertadosKey) // Guarda los IDs actualizados
          }
      }
    
    func toggleFavourite(for quiz: QuizItem) async throws {
        let urlString: String
        let method: String

        if quiz.favourite {
            urlString = "https://quiz.dit.upm.es/api/users/tokenOwner/favourites/\(quiz.id)?token=\(token)"
            method = "DELETE"
        } else {
            urlString = "https://quiz.dit.upm.es/api/users/tokenOwner/favourites/\(quiz.id)?token=\(token)"
            method = "PUT"
        }

        guard let url = URL(string: urlString) else {
            throw QuizzesModelError.internalError(msg: "URL no válida para actualizar favorito.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw QuizzesModelError.internalError(msg: "Error al actualizar favorito. Estado HTTP inválido.")
        }

        let favouriteResponse = try JSONDecoder().decode(FavouriteResponse.self, from: data)
        print(favouriteResponse)

        DispatchQueue.main.async {
            if let index = self.quizzes.firstIndex(where: { $0.id == favouriteResponse.id }) {
                self.quizzes[index].favourite = favouriteResponse.favourite
                print(self.quizzes[index].favourite)
            }
        }
    }

       struct FavouriteResponse: Codable {
           let id: Int
           let favourite: Bool
       }
    
    
}
