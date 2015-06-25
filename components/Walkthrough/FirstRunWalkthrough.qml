import QtQuick 2.3
import Ubuntu.Components 1.1
import "../../js/scripts.js" as Scripts

// Initial Walkthrough tutorial
Walkthrough {
    id: walkthrough
    objectName: "walkthroughPage"

    appName: "VK Music"

    onFinished: {
        walkthrough.visible = false
        pageStack.pop()
        firstRun = false
        Scripts.setKey("firstRun", "1")
    }

    model: [
        Slide1{},
        Slide2{},
        Slide3{},
        Slide4{},
        Slide5{}
    ]
}
