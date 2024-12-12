import Foundation

class QuizzesModel: ObservableObject {
    // Los datos
    @Published private(set) var quizzes = [QuizItem]()
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
    
    func toggleFavourite(for quiz: QuizItem) {
           guard let index = quizzes.firstIndex(where: { $0.id == quiz.id }) else { return }

           let isCurrentlyFavourite = quizzes[index].favourite
           let httpMethod = isCurrentlyFavourite ? "DELETE" : "PUT"
           let urlString = "https://quiz.dit.upm.es/api/users/tokenOwner/favourites/\(quiz.id)?token=\(token)"

           guard let url = URL(string: urlString) else { return }

           var request = URLRequest(url: url)
           request.httpMethod = httpMethod

           URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
               if let error = error {
                   print("Error al actualizar favorito: \(error.localizedDescription)")
                   return
               }

               guard let data = data else {
                   print("Error: No se recibieron datos")
                   return
               }

               do {
                   let result = try JSONDecoder().decode(FavouriteResponse.self, from: data)
                   DispatchQueue.main.async {
                       self?.quizzes[index].favourite = result.favourite
                   }
               } catch {
                   print("Error al decodificar la respuesta: \(error.localizedDescription)")
               }
           }.resume()
       }

       struct FavouriteResponse: Codable {
           let id: Int
           let favourite: Bool
       }
    
    
}
