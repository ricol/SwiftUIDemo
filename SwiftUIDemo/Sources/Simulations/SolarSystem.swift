import SwiftUI
import SceneKit
internal import Combine

// MARK: - Planet Data Model
struct Planet: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let radius: CGFloat           // Relative radius
    let distance: Float           // Distance from sun (scaled)
    let rotationSpeed: Double     // Speed of rotation
    let orbitSpeed: Double        // Speed of orbit
    let description: String
    let texture: String
    let hasRings: Bool
    let moons: Int

    static let sun = Planet(
        name: "Sun",
        color: .yellow,
        radius: 3.0,
        distance: 0,
        rotationSpeed: 25,
        orbitSpeed: 0,
        description: "The Sun is the star at the center of our solar system. It accounts for 99.86% of the total mass of the solar system.",
        texture: "sun",
        hasRings: false,
        moons: 0
    )

    static let mercury = Planet(
        name: "Mercury",
        color: .gray,
        radius: 0.4,
        distance: 4,
        rotationSpeed: 58.6,
        orbitSpeed: 0.24,
        description: "Mercury is the smallest and innermost planet in the solar system. It has no moons and a very thin atmosphere.",
        texture: "mercury",
        hasRings: false,
        moons: 0
    )

    static let venus = Planet(
        name: "Venus",
        color: .orange,
        radius: 0.9,
        distance: 6,
        rotationSpeed: 243,
        orbitSpeed: 0.62,
        description: "Venus is the second planet from the Sun. It's the hottest planet with temperatures reaching 462°C.",
        texture: "venus",
        hasRings: false,
        moons: 0
    )

    static let earth = Planet(
        name: "Earth",
        color: .blue,
        radius: 0.95,
        distance: 8,
        rotationSpeed: 1,
        orbitSpeed: 1,
        description: "Earth is our home planet. It's the only planet known to support life and has one moon.",
        texture: "earth",
        hasRings: false,
        moons: 1
    )

    static let mars = Planet(
        name: "Mars",
        color: .red,
        radius: 0.5,
        distance: 10,
        rotationSpeed: 1.03,
        orbitSpeed: 1.88,
        description: "Mars is the fourth planet from the Sun. Known as the Red Planet, it has two small moons.",
        texture: "mars",
        hasRings: false,
        moons: 2
    )

    static let jupiter = Planet(
        name: "Jupiter",
        color: .brown,
        radius: 2.0,
        distance: 14,
        rotationSpeed: 0.41,
        orbitSpeed: 11.86,
        description: "Jupiter is the largest planet in our solar system. It has 79 known moons and a Great Red Spot.",
        texture: "jupiter",
        hasRings: true,
        moons: 79
    )

    static let saturn = Planet(
        name: "Saturn",
        color: .yellow,
        radius: 1.7,
        distance: 18,
        rotationSpeed: 0.45,
        orbitSpeed: 29.46,
        description: "Saturn is famous for its beautiful rings. It's the second largest planet with 82 moons.",
        texture: "saturn",
        hasRings: true,
        moons: 82
    )

    static let uranus = Planet(
        name: "Uranus",
        color: .cyan,
        radius: 1.4,
        distance: 22,
        rotationSpeed: 0.72,
        orbitSpeed: 84.01,
        description: "Uranus rotates on its side, likely due to a massive collision. It has 27 known moons.",
        texture: "uranus",
        hasRings: true,
        moons: 27
    )

    static let neptune = Planet(
        name: "Neptune",
        color: .blue,
        radius: 1.4,
        distance: 26,
        rotationSpeed: 0.67,
        orbitSpeed: 164.8,
        description: "Neptune is the windiest planet with speeds reaching 2,100 km/h. It has 14 known moons.",
        texture: "neptune",
        hasRings: false,
        moons: 14
    )

    static let allPlanets = [mercury, venus, earth, mars, jupiter, saturn, uranus, neptune]
}

// MARK: - SceneKit View
struct SolarSystemSceneView: UIViewRepresentable {
    @Binding var selectedPlanet: Planet?
    let planets: [Planet]

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = createScene()
        scnView.backgroundColor = UIColor.black
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        scnView.showsStatistics = false

        // Set up camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 15, 35)
        scnView.scene?.rootNode.addChildNode(cameraNode)

        // Add lights
        setupLights(in: scnView.scene!.rootNode)

        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        guard let scene = scnView.scene else { return }

        // Remove existing planets (keep sun, orbits, and lights)
        scene.rootNode.childNodes.forEach { node in
            if node.name != "sun" && node.name != "orbit" && node.name != "light" {
                node.removeFromParentNode()
            }
        }

        // Add planets with updated positions
        for planet in planets {
            let planetNode = createPlanetNode(planet: planet)
            planetNode.name = planet.name

            // Add animation for orbit
            let orbitAnimation = createOrbitAnimation(for: planet)
            planetNode.addAnimation(orbitAnimation, forKey: "orbit")

            scene.rootNode.addChildNode(planetNode)

            // Add rings for Saturn and others
            if planet.hasRings {
                let ringNode = createRingNode(for: planet)
                planetNode.addChildNode(ringNode)
            }
        }
    }

    private func setupLights(in rootNode: SCNNode) {
        // Ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.3, alpha: 1.0)
        ambientLight.name = "light"
        rootNode.addChildNode(ambientLight)

        // Sun light (point light at center)
        let sunLight = SCNNode()
        sunLight.light = SCNLight()
        sunLight.light?.type = .omni
        sunLight.light?.color = UIColor(white: 1.0, alpha: 0.8)
        sunLight.position = SCNVector3(0, 0, 0)
        sunLight.name = "light"
        rootNode.addChildNode(sunLight)
    }

    private func createScene() -> SCNScene {
        let scene = SCNScene()

        // Create Sun
        let sunNode = createSunNode()
        sunNode.name = "sun"
        scene.rootNode.addChildNode(sunNode)

        // Create star field background
        let starsNode = createStarField()
        scene.rootNode.addChildNode(starsNode)

        // Create orbital paths
        for planet in Planet.allPlanets {
            let orbitNode = createOrbitNode(radius: CGFloat(planet.distance))
            orbitNode.name = "orbit"
            scene.rootNode.addChildNode(orbitNode)
        }

        return scene
    }

    private func createSunNode() -> SCNNode {
        let sphere = SCNSphere(radius: 3.0)
        sphere.firstMaterial?.diffuse.contents = UIColor.yellow
        sphere.firstMaterial?.emission.contents = UIColor.orange
        sphere.firstMaterial?.specular.contents = UIColor.white

        let sunNode = SCNNode(geometry: sphere)

        // Add glow effect
        let light = SCNLight()
        light.type = .omni
        light.color = UIColor(red: 1.0, green: 0.8, blue: 0.5, alpha: 1.0)
        sunNode.light = light

        return sunNode
    }

    private func createPlanetNode(planet: Planet) -> SCNNode {
        let sphere = SCNSphere(radius: CGFloat(planet.radius))

        // Set planet texture or color
        if let textureImage = UIImage(named: planet.texture) {
            sphere.firstMaterial?.diffuse.contents = textureImage
        } else {
            sphere.firstMaterial?.diffuse.contents = UIColor(planet.color)
        }

        sphere.firstMaterial?.specular.contents = UIColor.white
        sphere.firstMaterial?.shininess = 1.0

        let planetNode = SCNNode(geometry: sphere)

        // Position the planet
        planetNode.position = SCNVector3(planet.distance, 0, 0)

        // Add rotation animation
        let rotationAnimation = CABasicAnimation(keyPath: "rotation")
        rotationAnimation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        rotationAnimation.duration = planet.rotationSpeed
        rotationAnimation.repeatCount = .infinity
        planetNode.addAnimation(rotationAnimation, forKey: "rotation")

        return planetNode
    }

    private func createOrbitNode(radius: CGFloat) -> SCNNode {
        let orbitNode = SCNNode()

        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: 0, y: 0),
                    radius: radius,
                    startAngle: 0,
                    endAngle: CGFloat.pi * 2,
                    clockwise: true)

        let shape = SCNShape(path: path, extrusionDepth: 0.05)
        shape.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.2)
        shape.firstMaterial?.emission.contents = UIColor.white.withAlphaComponent(0.1)
        shape.firstMaterial?.isDoubleSided = true

        let shapeNode = SCNNode(geometry: shape)
        shapeNode.eulerAngles = SCNVector3(Float.pi/2, 0, 0)
        orbitNode.addChildNode(shapeNode)

        return orbitNode
    }

    private func createRingNode(for planet: Planet) -> SCNNode {
        let ring = SCNTorus(ringRadius: CGFloat(planet.radius * 1.5), pipeRadius: 0.1)
        ring.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
        ring.firstMaterial?.specular.contents = UIColor.white
        ring.firstMaterial?.emission.contents = UIColor.gray.withAlphaComponent(0.2)

        let ringNode = SCNNode(geometry: ring)
        ringNode.eulerAngles = SCNVector3(Float.pi/2, 0, 0)

        return ringNode
    }

    private func createOrbitAnimation(for planet: Planet) -> CAAnimation {
        let orbitAnimation = CAKeyframeAnimation(keyPath: "position")

        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: 0, y: 0),
                    radius: CGFloat(planet.distance),
                    startAngle: 0,
                    endAngle: CGFloat.pi * 2,
                    clockwise: true)

        orbitAnimation.path = UIBezierPath(cgPath: path.cgPath).cgPath
        orbitAnimation.duration = planet.orbitSpeed * 10 // Scale for visibility
        orbitAnimation.repeatCount = .infinity
        orbitAnimation.calculationMode = .paced
        orbitAnimation.rotationMode = .rotateAuto

        return orbitAnimation
    }

    private func createStarField() -> SCNNode {
        let starsNode = SCNNode()

        // Create particle system for stars
        let stars = SCNParticleSystem()
        stars.birthRate = 200
        stars.particleLifeSpan = 10
        stars.particleColor = UIColor.white
        stars.particleSize = 0.1
        stars.emitterShape = SCNSphere(radius: 50)
        stars.particleColorVariation = SCNVector4(0.5, 0.5, 0.5, 0)

        starsNode.addParticleSystem(stars)

        return starsNode
    }
}

// MARK: - Main Content View
struct SolarSystemView: View {
    @State private var selectedPlanet: Planet?
    @State private var showingInfo = false
    @State private var planets = Planet.allPlanets
    @State private var isAnimating = true
    @State private var speedMultiplier: Double = 1.0

    var body: some View {
        ZStack {
            // 3D Solar System View
            SolarSystemSceneView(selectedPlanet: $selectedPlanet, planets: planets)
                .edgesIgnoringSafeArea(.all)

            // UI Overlay
            VStack {
                // Top Bar
                HStack {
                    VStack(alignment: .leading) {
                        Text("Solar System")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)

                        Text("3D Interactive Model")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    Button(action: { showingInfo.toggle() }) {
                        Image(systemName: "info.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                Spacer()

                // Control Panel
                VStack(spacing: 20) {
                    // Speed Control
                    VStack {
                        Text("Animation Speed: \(speedMultiplier, specifier: "%.1f")x")
                            .foregroundColor(.white)

                        Slider(value: $speedMultiplier, in: 0.1...3.0, step: 0.1)
                            .accentColor(.orange)
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)

                    // Planet Quick Access
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(planets) { planet in
                                PlanetThumbnail(planet: planet)
                                    .onTapGesture {
                                        selectedPlanet = planet
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }

            // Planet Detail View
            if let planet = selectedPlanet {
                PlanetDetailView(planet: planet, isPresented: $selectedPlanet)
            }
        }
        .sheet(isPresented: $showingInfo) {
            InfoView()
        }
    }
}

// MARK: - Supporting Views
struct PlanetThumbnail: View {
    let planet: Planet

    var body: some View {
        VStack {
            Circle()
                .fill(planet.color)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: planet.color.opacity(0.5), radius: 5)

            Text(planet.name)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

struct PlanetDetailView: View {
    let planet: Planet
    @Binding var isPresented: Planet?
    @State private var offset: CGFloat = 1000

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.spring()) {
                        offset = 1000
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isPresented = nil
                        }
                    }
                }

            VStack(spacing: 20) {
                // Header
                HStack {
                    Text(planet.name)
                        .font(.system(size: 32, weight: .bold))

                    Spacer()

                    Button(action: {
                        withAnimation(.spring()) {
                            offset = 1000
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isPresented = nil
                            }
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }

                // Planet Visualization
                Circle()
                    .fill(planet.color)
                    .frame(width: 150, height: 150)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
                    .shadow(color: planet.color.opacity(0.5), radius: 20)

                // Description
                ScrollView {
                    Text(planet.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                // Stats
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    StatCard(title: "Radius", value: "\(planet.radius) Earth radii", icon: "ruler")
                    StatCard(title: "Distance", value: "\(Int(planet.distance)) AU", icon: "location")
                    StatCard(title: "Rotation", value: "\(planet.rotationSpeed) days", icon: "clock")
                    StatCard(title: "Orbit", value: "\(planet.orbitSpeed) years", icon: "globe")
                    StatCard(title: "Moons", value: "\(planet.moons)", icon: "moon.stars")
                    StatCard(title: "Rings", value: planet.hasRings ? "Yes" : "No", icon: "circle.dashed")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(radius: 10)
            )
            .padding()
            .offset(y: offset)
            .onAppear {
                withAnimation(.spring()) {
                    offset = 0
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct InfoView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Section("About the Solar System") {
                    Text("Our solar system consists of the Sun and everything that orbits around it, including 8 planets, dwarf planets, moons, asteroids, and comets.")
                        .padding(.vertical)
                }

                Section("Planets") {
                    ForEach(Planet.allPlanets) { planet in
                        HStack {
                            Circle()
                                .fill(planet.color)
                                .frame(width: 20, height: 20)

                            Text(planet.name)
                        }
                    }
                }

                Section("How to Use") {
                    Label("Drag to rotate the view", systemImage: "hand.draw")
                    Label("Pinch to zoom in/out", systemImage: "magnifyingglass")
                    Label("Tap planets for details", systemImage: "hand.tap")
                    Label("Adjust animation speed with slider", systemImage: "speedometer")
                }

                Section("Scale Note") {
                    Text("For visualization purposes, planet sizes and distances are not to scale. In reality, the solar system is mostly empty space with vast distances between planets.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Solar System Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SolarSystemView()
}
