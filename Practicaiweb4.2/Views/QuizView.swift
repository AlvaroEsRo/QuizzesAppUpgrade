import SwiftUI

struct QuizView: View {
    @State private var userInput = ""
    @State private var displayedText = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var quizzesAcertados: [QuizItem.ID]
    
    let quiz: QuizItem
    
    var body: some View {
        GeometryReader { geometry in  // Usamos GeometryReader para obtener las dimensiones de la pantalla
            VStack {
                if geometry.size.width > geometry.size.height {
                    // En horizontal, reorganizamos para que los elementos estén lado a lado
                    HStack(spacing: 20) {
                        leftColumn  // Columna de la izquierda
                        rightColumn  // Columna de la derecha (imagen)
                    }
                } else {
                    // En vertical, reorganizamos para apilar los elementos
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
    }
    
    var PreguntaEstrella: some View {
        
        HStack {
            Text(quiz.question)  // Mostrar la pregunta
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)  // Aseguramos que el texto ocupe el espacio disponible
            
            if quiz.favourite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .imageScale(.medium)
            } else {
                Image(systemName: "star")
                    .foregroundColor(.gray)
                    .imageScale(.medium)
            }
        }
        .padding([.top, .horizontal])
        
        
    }
    
    var Autor: some View {
        
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
                        .onTapGesture(count: 2){
                            userInput = quiz.answer
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
    
    // Columna de la izquierda que contiene la pregunta y el autor
    var leftColumn: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            PreguntaEstrella
            Autor
            BotonTexto
        
            }.padding(.bottom)
        }
    
    
  
    // Columna de la derecha con la imagen adjunta (si existe)
    var rightColumn: some View {
        
        ImagenQuiz
    }
    
    private var verticalView: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            PreguntaEstrella
            ImagenQuiz
            Autor
            BotonTexto
            }.padding(.bottom)
            
        }
}
        
        

    


