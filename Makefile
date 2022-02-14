DESTINATION := -destination 'platform=iOS Simulator,name=iPhone 13 Pro'

.PHONY: build-SherlockForms-Gallery
build-SherlockForms-Gallery:
	cd Examples/SherlockForms-Gallery.swiftpm && \
	xcodebuild build -scheme SherlockForms-Gallery $(DESTINATION) | xcpretty

.PHONY: build-SherlockHUD-Demo
build-SherlockHUD-Demo:
	cd Examples/SherlockHUD-Demo.swiftpm && \
	xcodebuild build -scheme SherlockHUD-Demo $(DESTINATION) | xcpretty
