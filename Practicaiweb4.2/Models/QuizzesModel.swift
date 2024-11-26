import Foundation

/// Errores producidos en el modelo de los Quizzes
enum QuizzesModelError: LocalizedError {
    case internalError(msg: String)
    case corruptedDataError
    case unknownError
    case networkError(msg: String)

    var errorDescription: String? {
        switch self {
        case .internalError(let msg):
            return "Error interno: \(msg)"
        case .corruptedDataError:
            return "Recibidos datos corruptos"
        case .unknownError:
            return "Algo chungo ha pasado"
        case .networkError(let msg):
            return "Error de red: \(msg)"
        }
    }
}

class QuizzesModel: ObservableObject {
    
    // Los datos
    @Published private(set) var quizzes = [QuizItem]()
    
    // Token y URL base
    private let token = "TOKEN"  // Reemplaza con tu token real
    private let baseURL = "https://quiz.dit.upm.es/api/quizzes/random10"
    
    /// Cargar los quizzes desde el servidor
    func load() {
        guard let url = URL(string: "\(baseURL)?token=\(token)") else {
            print(QuizzesModelError.internalError(msg: "URL inválida").errorDescription ?? "")
            return
        }
        
        // Inicia una petición al servidor
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    print(QuizzesModelError.networkError(msg: error.localizedDescription).errorDescription ?? "")
                    self.quizzes = []
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    print(QuizzesModelError.unknownError.errorDescription ?? "")
                    self.quizzes = []
                }
                return
            }
            
            do {
                let decodedQuizzes = try JSONDecoder().decode([QuizItem].self, from: data)
                DispatchQueue.main.async {
                    self.quizzes = decodedQuizzes
                    print("Quizzes descargados correctamente")
                }
            } catch {
                DispatchQueue.main.async {
                    print(QuizzesModelError.corruptedDataError.errorDescription ?? "")
                    self.quizzes = []
                }
            }
        }.resume()
    }
}
