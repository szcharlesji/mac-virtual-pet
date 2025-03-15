import Cocoa

@MainActor
class PetViewController: NSViewController {
    enum PetState {
        case walking
        case sitting
    }
    
    // Character name for loading images
    var characterName: String = "pet"
    
    private var wanderTimer: Timer?
    private var walkDuration: TimeInterval = 0
    private var sitDuration: TimeInterval = 0
    
    private var petImageView: NSImageView!
    private(set) var currentState: PetState = .sitting
    private var movingRight = true
    private var currentPosition: CGFloat = 0
    private var targetPosition: CGFloat = 0
    private var velocity: CGFloat = 0
    private var animationTimer: Timer?
    private var screenBounds: NSRect = .zero
    
    // Movement parameters that can be randomized
    private var maxWalkingVelocity: CGFloat = 2.0
    private var springStrengthFactor: CGFloat = 0.08
    
    // Define a smaller constrained area for the pet to move in
    private let constrainedWidth: CGFloat = 300
    
    // Animation frames
    private var sittingImage: NSImage?
    private var walkingImage: NSImage?
    private var walkingFlippedImage: NSImage?
    
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: constrainedWidth, height: 100))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        
        // Create pet image view
        petImageView = NSImageView(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
        petImageView.imageScaling = .scaleProportionallyUpOrDown
        view.addSubview(petImageView)
        
        // Load pet images
        loadImages()
        
        // Get screen bounds
        if let screen = NSScreen.main {
            screenBounds = screen.frame
        }
        
        // Start wandering
        startWandering()
    }
    
    private func loadImages() {
        // Print the bundle path for debugging
        print("Bundle path: \(Bundle.main.bundlePath)")
        print("Resource path: \(Bundle.main.resourcePath ?? "nil")")
        
        // Try to find the Resources directory
        if let resourcePath = Bundle.main.resourcePath {
            let characterDir = "\(resourcePath)/\(characterName)"
            print("Looking for character files in: \(characterDir)")
            
            // Check for sit.gif
            let sitPath = "\(characterDir)/sit.gif"
            if FileManager.default.fileExists(atPath: sitPath) {
                print("Found sit.gif at: \(sitPath)")
                sittingImage = NSImage(contentsOfFile: sitPath)
            } else {
                print("sit.gif not found at: \(sitPath)")
                // Try searching in different locations
                let altPath = "\(resourcePath)/Resources/\(characterName)/sit.gif"
                print("Trying alternate path: \(altPath)")
                if FileManager.default.fileExists(atPath: altPath) {
                    print("Found sit.gif at alternate path")
                    sittingImage = NSImage(contentsOfFile: altPath)
                }
            }
            
            // Check for walk.gif
            let walkPath = "\(characterDir)/walk.gif"
            if FileManager.default.fileExists(atPath: walkPath) {
                print("Found walk.gif at: \(walkPath)")
                walkingImage = NSImage(contentsOfFile: walkPath)
                // Create flipped version for left movement
                if let walkImage = walkingImage {
                    walkingFlippedImage = flipImageHorizontally(walkImage)
                }
            } else {
                print("walk.gif not found at: \(walkPath)")
                // Try searching in different locations
                let altPath = "\(resourcePath)/Resources/\(characterName)/walk.gif"
                print("Trying alternate path: \(altPath)")
                if FileManager.default.fileExists(atPath: altPath) {
                    print("Found walk.gif at alternate path")
                    walkingImage = NSImage(contentsOfFile: altPath)
                    // Create flipped version for left movement
                    if let walkImage = walkingImage {
                        walkingFlippedImage = flipImageHorizontally(walkImage)
                    }
                }
            }
        }
        
        // If no images were loaded, use placeholders
        if sittingImage == nil {
            print("Using placeholder for sitting")
            sittingImage = createPlaceholderImage(color: .green, text: "SIT")
        }
        
        if walkingImage == nil {
            print("Using placeholder for walking")
            walkingImage = createPlaceholderImage(color: .blue, text: "WALK")
            walkingFlippedImage = createPlaceholderImage(color: .red, text: "WALK←")
        }
    }
    
    private func createPlaceholderImage(color: NSColor, text: String) -> NSImage {
        let image = NSImage(size: NSSize(width: 100, height: 100))
        image.lockFocus()
        
        // Draw a colored rectangle
        color.setFill()
        NSBezierPath.fill(NSRect(x: 10, y: 10, width: 80, height: 80))
        
        // Add text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 30),
            .foregroundColor: NSColor.white,
            .paragraphStyle: paragraphStyle
        ]
        
        let textRect = NSRect(x: 10, y: 30, width: 80, height: 40)
        text.draw(in: textRect, withAttributes: attributes)
        
        image.unlockFocus()
        return image
    }
    
    func setState(_ state: PetState) {
        // Stop any existing animation
        animationTimer?.invalidate()
        
        currentState = state
        
        // Apply image based on state
        applyCurrentStateImage()
    }
    
    private func applyCurrentStateImage() {
        switch currentState {
        case .sitting:
            petImageView.image = sittingImage
            petImageView.animates = true
        case .walking:
            if movingRight {
                petImageView.image = walkingImage
            } else {
                petImageView.image = walkingFlippedImage
            }
            petImageView.animates = true
        }
    }
    
    private func startWandering() {
        wanderTimer?.invalidate()
        startRandomWalk()
    }
    
    private func startRandomWalk() {
        let margin: CGFloat = 20
        // Constrain the pet's movement to the small area
        let maxX = constrainedWidth - petImageView.frame.width - margin
        
        // For longer walks, try to make the pet travel a greater distance
        let currentX = currentPosition
        let availableDistance = maxX - margin
        
        // Try to pick a target that's at least 1/3 of the available width away
        // but still within the constrained area
        let minDistance = availableDistance / 3
        var newTarget: CGFloat
        
        if Bool.random() {
            // Move right
            newTarget = min(maxX, currentX + minDistance + CGFloat.random(in: 0...minDistance))
        } else {
            // Move left
            newTarget = max(margin, currentX - minDistance - CGFloat.random(in: 0...minDistance))
        }
        
        targetPosition = newTarget
        
        // Determine direction
        movingRight = targetPosition > currentPosition
        
        // Use only one consistent walking speed instead of randomizing
        maxWalkingVelocity = 2.0
        springStrengthFactor = 0.08
        
        setState(.walking)
        walkDuration = TimeInterval.random(in: 5...8) // Walking times, 5-8 seconds
        
        // Start moving the pet
        startMovementAnimation()
        
        wanderTimer = Timer.scheduledTimer(withTimeInterval: walkDuration, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.startSitting()
            }
        }
    }
    
    private func startSitting() {
        setState(.sitting)
        sitDuration = TimeInterval.random(in: 3...10) // Longer sitting times, 3-10 seconds
        
        wanderTimer = Timer.scheduledTimer(withTimeInterval: sitDuration, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.startRandomWalk()
            }
        }
    }
    
    private func startMovementAnimation() {
        // Run movement animation at 60 fps
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, self.currentState == .walking else { return }
                self.updatePetPosition()
                
                // Check if direction changed and update the image
                if self.movingRight != (self.velocity > 0) {
                    self.movingRight = self.velocity > 0
                    self.applyCurrentStateImage()
                }
            }
        }
    }
    
    private func flipImageHorizontally(_ image: NSImage) -> NSImage {
        let flippedImage = NSImage(size: image.size)
        
        flippedImage.lockFocus()
        
        // Apply a transformation to flip horizontally
        let transform = NSAffineTransform()
        transform.translateX(by: image.size.width, yBy: 0)
        transform.scaleX(by: -1, yBy: 1)
        transform.concat()
        
        // Draw the original image with the transform applied
        image.draw(in: NSRect(origin: .zero, size: image.size),
                  from: NSRect(origin: .zero, size: image.size),
                  operation: .copy,
                  fraction: 1.0)
        
        flippedImage.unlockFocus()
        
        return flippedImage
    }
    
    private func updatePetPosition() {
        // Calculate distance to target
        let distance = targetPosition - currentPosition
        
        // If we reach the target, just change direction instead of stopping early
        if abs(distance) < 2 && abs(velocity) < 0.1 {
            // Change direction or get a new target instead of ending the walk
            if currentPosition < constrainedWidth / 2 {
                targetPosition = constrainedWidth - petImageView.frame.width - 10
            } else {
                targetPosition = 10
            }
            
            // Update direction
            movingRight = targetPosition > currentPosition
            applyCurrentStateImage()
            return
        }
        
        // Apply spring physics for smooth movement
        let springStrength: CGFloat = springStrengthFactor
        let dampening: CGFloat = 0.85  // Adjusted for faster movement
        
        // Calculate spring force
        let springForce = distance * springStrength
        
        // Update velocity with spring force and dampening
        velocity = (velocity + springForce) * dampening
        
        // Limit maximum velocity - now using the randomized max velocity
        if abs(velocity) > maxWalkingVelocity {
            velocity = velocity > 0 ? maxWalkingVelocity : -maxWalkingVelocity
        }
        
        // Update position using velocity
        currentPosition += velocity
        
        // Ensure Pet stays within constrained area
        let margin: CGFloat = 10
        let minX = margin
        let maxX = constrainedWidth - petImageView.frame.width - margin
        currentPosition = max(minX, min(maxX, currentPosition))
        
        // Update pet position
        petImageView.frame.origin.x = currentPosition
        
        // Ensure y position stays at bottom of the window
        petImageView.frame.origin.y = 0
    }
    
    // Simplified method - no longer handles mouse movement
    func handleMouseMovement(to position: NSPoint) {
        // Empty implementation since we don't want mouse interaction
    }
}
