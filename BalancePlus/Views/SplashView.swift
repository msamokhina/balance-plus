import SwiftUI
import Lottie

struct SplashView: View {
    @Binding var showSplash: Bool
    
    var body: some View {
        ZStack {
            Color
                .white
                .edgesIgnoringSafeArea(.all)
            
            LottieView(animationName: "splash_animation") {
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.5)) {
                        self.showSplash = false
                    }
                }
            }
        }
    }
}

struct LottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .playOnce
    var onCompletion: (() -> Void)? = nil

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: animationName)
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        animationView.play { finished in
            if finished {
                onCompletion?()
            }
        }
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
