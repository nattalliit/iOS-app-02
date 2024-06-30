//
//  ViewController.swift
//  ImageFiltering

import UIKit

class FilterViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    enum SLIDER_CASE {
        case contrast
        case brightness
        case grey
        case sepia
        case sketch
    }
    var currentSliderCase:SLIDER_CASE = .contrast

    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet weak var bottomMenu: UIView!
    @IBOutlet var editingBarMenu: UIView!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    // Bottom menu buttons.
    @IBOutlet weak var newMenuButton: UIButton!
    @IBOutlet weak var filterMenuButton: UIButton!
    @IBOutlet weak var shareMenuButton: UIButton!
    @IBOutlet weak var undoMenuButton: UIButton!
    @IBOutlet weak var compareMenuButton: UIButton!
    
    
    // Filter menu buttons.
    @IBOutlet weak var contrastButton: UIButton!
    @IBOutlet weak var brightnessButton: UIButton!
    @IBOutlet weak var greyButton: UIButton!
    @IBOutlet weak var sepiaButton: UIButton!
    @IBOutlet weak var sketchButton: UIButton!
    
    // Current values.
    var contrastLevel:Float = 0
    var brightnessLevel:Float = 0
    var greyLevel:Float = 0
    var sepiaLevel:Float = 0
    var sketchLevel:Float = 0
    
    @IBOutlet weak var editingValueSlider: UISlider!
    
    @IBOutlet weak var filterStackView: UIStackView!
    
    var originalImage:UIImage!
    var currentImage:UIImage!
    
    // List containing the history of changes.
    var imageHistoryList = [UIImage]()
    
    var isComparing:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        secondaryMenu.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        editingBarMenu.translatesAutoresizingMaskIntoConstraints = false
        editingBarMenu.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        photoImageView.isUserInteractionEnabled = true
        
        checkIfCurrentImageExists()
        
        setDynamicButtonActions()
    }
    
    func checkIfCurrentImageExists(){
        var exist:Bool = false
        if currentImage != nil && photoImageView.image != nil {
            exist = true
        }
        
        filterMenuButton.isEnabled = exist
        shareMenuButton.isEnabled = exist
        
        checkIfUndoable()
    }
    
    // MARK:- Select Photo Methods
    
    @IBAction func selectPhotoAction(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: "Add a new photo from...", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            self.showCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: {
            action in
            self.showAlbum()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera(){
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum(){
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .savedPhotosAlbum
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            // Resize to 1/4 of the value to faster processing.
            let resizedImage = image.resized(withPercentage: 0.25)
            
            originalImage = resizedImage
            currentImage = resizedImage
            
            swapImage(swap: photoImageView, to: resizedImage!)
        }
        checkIfCurrentImageExists()
        unselectAllButtons()
        dismiss(animated: true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil)
    }
    
    
    @IBAction func filterButtonAction(_ sender: UIButton) {
        
        if sender.isSelected {
            hideSecondaryMenu()
            sender.isSelected = false
        } else{
            showSecondaryMenu()
            sender.isSelected = true
        }
    }
    

    // MARK:- Show Filters Methods
    
    func showSecondaryMenu(){
        view.addSubview(secondaryMenu)
        
        let bottomContraint = secondaryMenu.bottomAnchor.constraint(equalTo: photoImageView.bottomAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraint(equalTo: view.rightAnchor)
        
        let heightConstraint = secondaryMenu.heightAnchor.constraint(equalToConstant: 68)
        
        NSLayoutConstraint.activate([bottomContraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animate(withDuration: 0.4){
            self.secondaryMenu.alpha = 1.0
        }
    }
    
    func hideSecondaryMenu(){
        if self.editingBarMenu.isDescendant(of: self.view) {
            self.editingBarMenu.alpha = 0
            self.editingBarMenu.removeFromSuperview()
        }
        UIView.animate(withDuration: 0.4, animations: {
            self.secondaryMenu.alpha = 0
        }){ completed in
            if completed {
                self.secondaryMenu.removeFromSuperview()
                self.unselectAllButtons()
            }
        }
    }
    
    
    // MARK:- Share Methods
    @IBAction func shareAction(_ sender: Any) {
        
        if photoImageView.image == nil { return }
        
        let activityController = UIActivityViewController(activityItems: [photoImageView.image!], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed {
                let alert = UIAlertController(title: "Share successful!", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
        
        present(activityController, animated: true, completion: nil)
    }
    
    // MARK:- Filtering Actions
    
    func setDynamicButtonActions(){
        contrastButton.addTarget(self, action: #selector(showEditingSliderProxy), for: .touchUpInside)
        brightnessButton.addTarget(self, action: #selector(showEditingSliderProxy), for: .touchUpInside)
        greyButton.addTarget(self, action: #selector(showEditingSliderProxy), for: .touchUpInside)
        sepiaButton.addTarget(self, action: #selector(showEditingSliderProxy), for: .touchUpInside)
        sketchButton.addTarget(self, action: #selector(showEditingSliderProxy), for: .touchUpInside)
        
        editingValueSlider.addTarget(self, action: #selector(self.sliderDidEndSliding), for: .touchUpInside)
    }
    
    @objc func sliderDidEndSliding(sender: UISlider) {
        if currentSliderCase == .contrast {
            contrastLevel = sender.value
            contrastFilterAction(amount: Int(contrastLevel))
        }
        else if currentSliderCase == .brightness {
            brightnessLevel = sender.value
            brightnessFilterAction(amount: Int(brightnessLevel))
        }
        else if currentSliderCase == .grey {
            greyLevel = sender.value
            greyFilterAction(amount: Double(greyLevel))
        }
        else if currentSliderCase == .sepia {
            sepiaLevel = sender.value
            sepiaFilterAction(amount: Double(sepiaLevel))
        }
        else if currentSliderCase == .sketch {
            sketchLevel = sender.value
            sketchFilterAction(amount: Double(sketchLevel))
       }
    }
    
    @objc func showEditingSliderProxy(_ sender:UIButton){
        
        if self.editingBarMenu.isDescendant(of: self.view) {
            self.editingBarMenu.alpha = 0
            self.editingBarMenu.removeFromSuperview()
            
            contrastButton.isSelected = false
            brightnessButton.isSelected = false
            greyButton.isSelected = false
            sepiaButton.isSelected = false
            sketchButton.isSelected = false
            
            self.editingValueSlider.value = 0
        }
        
        if sender == contrastButton {

            editingValueSlider.value = contrastLevel
            currentSliderCase = .contrast
            
            changeSliderTreshold(min: 0, max: 255.0)
            
        }
        else if sender == brightnessButton {
            
            editingValueSlider.value = brightnessLevel
            currentSliderCase = .brightness
            
            changeSliderTreshold(min: 0, max: 124.0)

        }
        else if sender == greyButton {
            editingValueSlider.value = greyLevel
            currentSliderCase = .grey
            
            changeSliderTreshold(min: 0, max: 0.5)

        }
        else if sender == sepiaButton {
            editingValueSlider.value = sepiaLevel
            currentSliderCase = .sepia
            
            changeSliderTreshold(min: 0, max: 0.5)

        }
        else if sender == sketchButton {
            editingValueSlider.value = sketchLevel
            currentSliderCase = .sketch
            
            changeSliderTreshold(min: 0, max: 0.5)
            
        }
        
        if sender.isSelected {
            hideFilterEditingMenu()
            sender.isSelected = false
        } else{
            showFilterEditingMenu()
            sender.isSelected = true
        }
        
    }
    
    func changeSliderTreshold(min:Float, max:Float){
        editingValueSlider.minimumValue = min
        editingValueSlider.maximumValue = max
    }
    
    func showFilterEditingMenu(){
        
        view.addSubview(editingBarMenu)
        
        let bottomContraint = editingBarMenu.bottomAnchor.constraint(equalTo: secondaryMenu.topAnchor)
        let leftConstraint = editingBarMenu.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = editingBarMenu.rightAnchor.constraint(equalTo: view.rightAnchor)
        
        let heightConstraint = editingBarMenu.heightAnchor.constraint(equalToConstant: 65)
        
        NSLayoutConstraint.activate([bottomContraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.editingValueSlider.value = 0
        self.editingBarMenu.alpha = 0
        UIView.animate(withDuration: 0.4){
            self.editingBarMenu.alpha = 1.0
        }
    }
    
    func hideFilterEditingMenu(){
        UIView.animate(withDuration: 0.4, animations: {
            self.editingBarMenu.alpha = 0
        }){ completed in
            if completed {
                self.editingBarMenu.removeFromSuperview()
                
            }
        }
    }
    
    func contrastFilterAction(amount:Int) {
        let myRGBA = RGBAImage(image: originalImage!)!
        let image:UIImage = ImageFilters.amplifyContrastFilter(image: myRGBA, by: amount)
        applyFiltered(image: image)
    }
    
    func brightnessFilterAction(amount:Int) {
        let myRGBA = RGBAImage(image: originalImage!)!
        let image:UIImage = ImageFilters.amplifyBrightnessFilter(image: myRGBA, by: amount)
        applyFiltered(image: image)
    }
    
    func greyFilterAction(amount:Double){
        let myRGBA = RGBAImage(image: originalImage!)!
        let image:UIImage = ImageFilters.greyFilter(image: myRGBA, intensityFactor: amount)
        applyFiltered(image: image)
    }
    
    func sepiaFilterAction(amount:Double){
        let myRGBA = RGBAImage(image: originalImage!)!
        let image:UIImage = ImageFilters.sepiaFilter(image: myRGBA, intensityFactor: amount)
        applyFiltered(image: image)
    }
    
    func sketchFilterAction(amount:Double){
        let myRGBA = RGBAImage(image: originalImage!)!
        let image:UIImage = ImageFilters.sketchFilter(image: myRGBA, intensityFactor: amount)
        applyFiltered(image: image)
    }
    
    
    func applyFiltered(image:UIImage){
        
        imageHistoryList.append(image)
        
        currentImage = image
        photoImageView.image = image
        
        checkIfUndoable()
    }
    
    // MARK:- Undo Methods.
    
    @IBAction func undoAction(_ sender: Any) {
        
        // Reset slider values.
        if self.editingBarMenu.isDescendant(of: self.view) {
            self.editingValueSlider.value = 0
        }
        
        if imageHistoryList.count > 0 {
            imageHistoryList.removeLast()
            
            if imageHistoryList.isEmpty {
                currentImage = originalImage
                photoImageView.image = originalImage
            }else{
                currentImage = imageHistoryList.last
                photoImageView.image = imageHistoryList.last
            }
        }
        else {
            currentImage = originalImage
            photoImageView.image = originalImage
        }
        
        checkIfUndoable()
    }
    
    func checkIfUndoable(){
        if imageHistoryList.count > 0 {
            undoMenuButton.isEnabled = true
            compareMenuButton.isHidden = false
        }
        else {
            undoMenuButton.isEnabled = false
            compareMenuButton.isHidden = true
        }
    }
    
    // MARK:- Compare Methods
    
    @IBAction func compareAction(_ sender: UIButton) {
        if sender.isSelected {
            hideOriginalImage()
            sender.isSelected = false
            isComparing = false
            undoMenuButton.isEnabled = true
        } else{
            showOriginalImage()
            sender.isSelected = true
            isComparing = true
            undoMenuButton.isEnabled = false
        }
    }
    
    
    // Show original image.
    var label:UILabel!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        
        if isComparing { return }
        
        if touch.view == photoImageView {
            
            showOriginalImage()
            undoMenuButton.isEnabled = false
        }

    }
    
    // Show current image.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        
        if isComparing { return }
        
        if touch.view == photoImageView {
            hideOriginalImage()
            
            if !imageHistoryList.isEmpty {
                undoMenuButton.isEnabled = true
            }
        }

    }
    
    func unselectAllButtons(){
        
        if self.editingBarMenu.isDescendant(of: self.view) {
            self.editingBarMenu.removeFromSuperview()
        }
        
        if contrastButton.isSelected {
            contrastButton.isSelected = false
        }
        if brightnessButton.isSelected {
            brightnessButton.isSelected = false
        }
        if greyButton.isSelected {
            greyButton.isSelected = false
        }
        if sepiaButton.isSelected {
            sepiaButton.isSelected = false
        }
        if sketchButton.isSelected {
            sketchButton.isSelected = false
        }
    }
    
    func showOriginalImage(){
        
        if originalImage == nil { return }
        
        if imageHistoryList.isEmpty{ return }
        
        unselectAllButtons()
        
        swapImage(swap: photoImageView, to: originalImage)
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 4))
        label.textAlignment = .center
        label.text = "Showing original image"
        label.textColor = UIColor.systemPink
        view.addSubview(label)
        
    }
    
    func hideOriginalImage(){
        
        if originalImage == nil { return }
        
        if imageHistoryList.isEmpty{ return }
        
        swapImage(swap: photoImageView, to: currentImage)
        if label != nil {
            label.removeFromSuperview()
        }
    }
    
    func swapImage(swap imageView:UIImageView, to dest:UIImage){
        imageView.alpha = 1.0
        UIView.animate(withDuration: 0.2, animations: {
            imageView.alpha = 0
        }){ completed in
            if completed {
                imageView.image = dest
                UIView.animate(withDuration: 0.2){
                    imageView.alpha = 1.0
                }
            }
        }
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
