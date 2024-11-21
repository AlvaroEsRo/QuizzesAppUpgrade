import SwiftUI

struct QuizView: View {
    @State private var userInput = ""
    @State private var displayedText = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var quizzesAcertados: [QuizItem.ID]
    
    let quiz: QuizItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Encabezado con la pregunta
            HStack {
                Text(quiz.question)  // Mostrar la pregunta
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                if quiz.favourite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .imageScale(.medium)
                } else {
                    Image(systemName: "star")
                        .foregroundColor(.gray)
                        .imageScale(.medium)
                }
                
                Spacer()
                
            }
            .padding([.top, .horizontal])
            
            // Imagen adjunta, si existe
            if let imageUrl = quiz.attachment?.url {
                AsyncImage(url: imageUrl) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 250)
                        .cornerRadius(12)
                        .clipped()
                        .shadow(radius: 4)
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .frame(maxWidth: .infinity, maxHeight: 250)
                }
                .padding(.horizontal)
            }
            
            // Información del autor
            HStack(spacing: 12) {
                if let autorphoto = quiz.author?.photo?.url {
                    AsyncImage(url: autorphoto) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .background(Circle().fill(Color.gray.opacity(0.2)))
                            .padding(2)
                    }
                }
                
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
            
            // Entrada del usuario (campo de texto para la respuesta)
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
                
                // Botón para comprobar la respuesta
                Button(action: {
                    displayedText = userInput
                    if displayedText.lowercased() == quiz.answer.lowercased() {
                        // Respuesta correcta
                        alertMessage = "¡Enhorabuena!"
                        quizzesAcertados.append(quiz.id)
                    } else {
                        // Respuesta incorrecta
                        alertMessage = "Respuesta Incorrecta. Inténtalo otra vez."
                    }
                    showAlert = true
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
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .padding(.top, 10)
            }
            .padding(.bottom)
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 8)
        .padding([.horizontal, .top])
        .frame(maxWidth: .infinity)
    }
}


