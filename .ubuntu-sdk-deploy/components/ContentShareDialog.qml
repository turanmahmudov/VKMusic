import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.0
import Ubuntu.Content 0.1

PopupBase {
    id: shareDialog
    anchors.fill: parent
    property var activeTransfer
    property var selectedItems
    property var path
    property alias contentType: peerPicker.contentType

    Rectangle {
        anchors.fill: parent
        ContentPeerPicker {
            id: peerPicker
            handler: ContentHandler.Share
            visible: parent.visible
            contentType: ContentType.Links

            onPeerSelected: {
                activeTransfer = peer.request()
                activeTransfer.state = ContentTransfer.Charged
                var contentItems = [];
                contentItems.push(shareComponent.createObject(mainView, {"url": path}))
                activeTransfer.items = contentItems;
                activeTransfer.state = ContentTransfer.Charged;

                PopupUtils.close(shareDialog)
            }

            onCancelPressed: {
                PopupUtils.close(shareDialog)
            }
        }
    }
}
