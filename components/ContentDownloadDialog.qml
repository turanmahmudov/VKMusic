import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Content 0.1

PopupBase {
    id: downloadDialog
    anchors.fill: parent
    property var activeTransfer
    property var selectedItems
    property var downloadId
    property var path
    property alias contentType: peerPicker.contentType

    Rectangle {
        anchors.fill: parent
        ContentPeerPicker {
            id: peerPicker
            handler: ContentHandler.Destination
            visible: parent.visible
            contentType: ContentType.Music

            onPeerSelected: {
                activeTransfer = peer.request()
                activeTransfer.downloadId = downloadDialog.downloadId
                activeTransfer.state = ContentTransfer.Downloading
                stateChangeConnection.target = activeTransfer
            }

            onCancelPressed: {
                PopupUtils.close(downloadDialog)
            }
        }
    }

    Connections {
        id: stateChangeConnection
        onStateChanged: {
            //console.log("Transfer state is " + activeTransfer.state + " " + ContentTransfer.Charged)
            if (activeTransfer.state === ContentTransfer.InProgress) {
                var contentItems = [];
                contentItems.push(transferComponent.createObject(mainView, {"url": path}))
                activeTransfer.items = contentItems;
                activeTransfer.state = ContentTransfer.Charged;

                PopupUtils.close(downloadDialog)
            }
        }
    }
}
