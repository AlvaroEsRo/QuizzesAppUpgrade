import SwiftUI

struct QuizView: View {
    @State private var userInput = ""
    @State private var displayedText = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var rotateImage = 0.0
    @State private var animateImage = false
    @Binding var quizzesAcertados: [QuizItem.ID]
    @StateObject private var quizzesModel = QuizzesModel()

    private let token = "31672ec34248438c2a53" // Sustituir con el token proporcionado

    let quiz: QuizItem
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                
                if geometry.size.width > geometry.size.height {
                    HStack(spacing: 20) {
                        leftColumn
                        rightColumn
                    }
                } else {
                    VStack(spacing: 20) {
                        verticalView
                    }
                }
            }
            .padding([.horizontal, .top])
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    var PreguntaEstrella: some View {
        HStack {
            Text(quiz.question)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Botón para alternar el estado favorito
            Button(action: {
                quizzesModel.toggleFavourite(for: quiz) // Alterna el favorito en el modelo
            }) {
                Image(systemName: quiz.favourite ? "star.fill" : "star")
                    .foregroundColor(quiz.favourite ? .yellow : .gray)
                    .imageScale(.medium)
            }
        }
        .padding([.top, .horizontal])
    }
    
    var Autor: some View {
        HStack(spacing: 12) {
            Group {
                 if let autorPhoto = quiz.author?.photo?.url {
                     AsyncImage(url: autorPhoto) { image in
                         image
                             .resizable()
                             .scaledToFill()
                             .frame(width: 50, height: 50)
                             .clipShape(Circle())
                             .contextMenu {
                                 Button("Limpiar respuesta") {
                                     userInput = "" // Limpia el campo de texto
                                 }
                                 Button("Rellenar con respuesta correcta") {
                                     obtenerRespuestaCorrecta()
                                 }
                             }
                     } placeholder: {
                         ProgressView()
                             .frame(width: 50, height: 50)
                             .background(Circle().fill(Color.gray.opacity(0.2)))
                             .contextMenu {
                                 Button("Limpiar respuesta") {
                                     userInput = "" // Limpia el campo de texto
                                 }
                                 Button("Rellenar con respuesta correcta") {
                                     obtenerRespuestaCorrecta()
                                 }
                             }
                     }
                 } else {
                     Circle()
                         .fill(Color.gray.opacity(0.2))
                         .frame(width: 100, height: 100)
                         .overlay(Text("Sin foto").foregroundColor(.gray))
                         .contextMenu {
                             Button("Limpiar respuesta") {
                                 userInput = "" // Limpia el campo de texto
                             }
                             Button("Rellenar con respuesta correcta") {
                                 obtenerRespuestaCorrecta()
                             }
                         }
                 }
             }
             .padding()
            
            if let author = quiz.author {
                Text(author.profileName ?? "Desconocido")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    var BotonTexto: some View {
        VStack {
            TextField("Escribe la respuesta aquí", text: $userInput)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.body)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .frame(height: 45)
                .cornerRadius(10)
                .padding(.horizontal)
            
            Button(action: {
                checkAnswer()
            }) {
                Text("Comprobar respuesta")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 300, height: 30, alignment: .center)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
    }
    
    var ImagenQuiz: some View {
        Group {
            if let imageUrl = quiz.attachment?.url {
                AsyncImage(url: imageUrl) { image in
                    image.resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .clipped()
                        .shadow(radius: 4)
                        .frame(height: 200)
                        .rotationEffect(.degrees(rotateImage))
                        .onTapGesture(count: 2) {
                            withAnimation(.linear(duration: 2.0)) {
                                rotateImage = 720
                                obtenerRespuestaCorrecta()
                            }
                        }
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .frame(width: 200, height: 200)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                }
                .padding([.horizontal, .top, .bottom])
            }
        }
    }
    
    private var verticalView: some View {
        VStack(alignment: .leading, spacing: 20) {
            PreguntaEstrella
            ImagenQuiz
            Autor
            BotonTexto
        }.padding(.bottom)
    }
    
    private var leftColumn: some View {
        VStack(alignment: .leading, spacing: 20) {
            PreguntaEstrella
            Autor
            BotonTexto
        }.padding(.bottom)
    }
    
    private var rightColumn: some View {
        ImagenQuiz
    }
    
    private func checkAnswer() {
        let token = "31672ec34248438c2a53"
        let escapedAnswer = userInput.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://quiz.dit.upm.es/api/quizzes/\(quiz.id)/check?answer=\(escapedAnswer)&token=\(token)"
        
        guard let url = URL(string: urlString) else {
            alertMessage = "URL inválida"
            showAlert = true
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "Error al comprobar respuesta: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    alertMessage = "Error: No se recibieron datos"
                    showAlert = true
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(CheckAnswerResponse.self, from: data)
                DispatchQueue.main.async {
                    if response.result {
                        alertMessage = "¡Enhorabuena! Respuesta correcta."
                        quizzesAcertados.append(quiz.id)
                        quizzesModel.markQuizAsCorrect(id: quiz.id)
                    } else {
                        alertMessage = "Respuesta incorrecta. Inténtalo de nuevo."
                    }
                    showAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    alertMessage = "Error al procesar la respuesta: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }.resume()
    }

    
    struct CheckAnswerResponse: Codable {
        let quizId: Int
        let answer: String
        let result: Bool
    }
    
    private func obtenerRespuestaCorrecta() {
        guard let url = URL(string: "https://quiz.dit.upm.es/api/quizzes/\(quiz.id)/answer?token=\(token)") else {
            alertMessage = "URL inválida"
            showAlert = true
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    alertMessage = "Error: No se recibieron datos"
                    showAlert = true
                }
                return
            }

            do {
                let respuesta = try JSONDecoder().decode(RespuestaCorrecta.self, from: data)
                DispatchQueue.main.async {
                    userInput = respuesta.answer // Rellena el campo con la respuesta correcta
                }
            } catch {
                DispatchQueue.main.async {
                    alertMessage = "Error al procesar la respuesta correcta"
                    showAlert = true
                }
            }
        }.resume()
    }

    struct RespuestaCorrecta: Codable {
        let quizId: Int
        let answer: String
    }
}
