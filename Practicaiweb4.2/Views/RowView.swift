import SwiftUI

struct RowView: View {
    let quiz: QuizItem  // Modelo de datos del quiz
    
    @State private var isLandscape: Bool = UIDevice.current.orientation.isLandscape
    
    var body: some View {
        VStack {
            if isLandscape {
                horizontalView  // Vista Horizontal
            } else {
                verticalView  // Vista Vertical
            }
        }
        .onAppear {
            // Detectar orientación inicial al cargar la vista
            updateOrientation()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            // Detectar cambios en la orientación
            updateOrientation()
        }
    }
    
    // Detectar la orientación actual del dispositivo
    private func updateOrientation() {
        let orientation = UIDevice.current.orientation
        isLandscape = orientation == .landscapeLeft || orientation == .landscapeRight
    }
    
    // Vista Horizontal
    private var horizontalView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                // Pregunta y estrella
                HStack {
                    Text(quiz.question)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                    
                    Spacer()
                    
                    Image(systemName: quiz.favourite ? "star.fill" : "star")
                        .foregroundColor(quiz.favourite ? .yellow : .gray)
                }
                
                // Autor
                HStack(spacing: 12) {
                    if let authorPhotoURL = quiz.author?.photo?.url {
                        AsyncImage(url: authorPhotoURL) { image in
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        } placeholder: {
                            ProgressView()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        }
                    }
                    
                    Text(quiz.author?.profileName ?? "Autor Desconocido")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            Spacer()
            
            // Imagen del quiz
            if let quizImageURL = quiz.attachment?.url {
                AsyncImage(url: quizImageURL) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 150)
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView()
                        .frame(width: 150, height: 150)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private var verticalView: some View {
        VStack(spacing: 8) {
            // Pregunta y estrella
            HStack {
                Text(quiz.question)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                Spacer()
                
                Image(systemName: quiz.favourite ? "star.fill" : "star")
                    .foregroundColor(quiz.favourite ? .yellow : .gray)
            }
            
            // Imagen del quiz
            if let quizImageURL = quiz.attachment?.url {
                AsyncImage(url: quizImageURL) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView()
                        .frame(height: 150)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            // Autor (foto y nombre alineados a la izquierda)
            HStack(spacing: 12) {
                if let authorPhotoURL = quiz.author?.photo?.url {
                    AsyncImage(url: authorPhotoURL) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    } placeholder: {
                        ProgressView()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    }
                }
                
                Text(quiz.author?.profileName ?? "Autor Desconocido")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer() // Asegura que todo lo demás esté alineado a la izquierda
            }
        }
        .padding()
    }

}
