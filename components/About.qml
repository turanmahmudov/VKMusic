import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Popups 1.0

Item {
    id: about

    property string version : '0.2'

    Loader {
        id: view

        anchors {
            fill: parent
            margins: units.gu(2)
        }

        sourceComponent: {
            return aboutSection
        }
    }

    Component {
        id: aboutSection

        Flickable {
            id: flickable
            anchors.fill: parent
            clip: true
            contentHeight: aboutColumn.height

            Column {
                id: aboutColumn
                anchors.centerIn: parent
                width: parent.width > units.gu(50) ? units.gu(50) : parent.width

                UbuntuShape {
                    id: logo
                    width: parent.width > units.gu(50) ? units.gu(17) : parent.width / 3
                    height: width
                    radius: "medium"

                    image: Image {
                        source: "../VKMusic.png"
                        width: parent.width
                        height: width
                    }

                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Item {
                    width: parent.width
                    height: units.gu(2)
                }

                Column {
                    width: parent.width

                    Label {
                        fontSize: "x-large"
                        font.weight: Font.DemiBold
                        text: "VK Music"

                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Label {
                        text: i18n.tr("Version ") + about.version
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Item {
                        width: parent.width
                        height: units.gu(2)
                    }

                    Label {
                        text: "Developed by Turan Mahmudov"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Label {
                        fontSize: "small"
                        text: i18n.tr("Released under the terms of the GNU GPL v3")
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                Item {
                    width: parent.width
                    height: units.gu(3)
                }

                Column {
                    width: parent.width
                    spacing: units.gu(2)

                    Row {
                        spacing: units.gu(1)
                        Icon {
                            y: units.gu(0.1)
                            name: "info"
                            width: units.gu(2)
                            height: width
                        }

                        Label {
                            id: awareLabel
                            width: units.gu(35)
                            text: i18n.tr("The app is <b>not</b> provided by VK.")
                            textFormat: Text.RichText
                            wrapMode: Text.WordWrap
                        }
                    }

                    Row {
                        spacing: units.gu(1)
                        Icon {
                            y: units.gu(0.2)
                            name: "like"
                            color: "#ff0000"
                            width: units.gu(2)
                            height: width
                        }

                        Label {
                            id: donateLabel
                            width: units.gu(35)
                            text: i18n.tr("Buy <b>VK Music Pro</b> to donate me.")
                            textFormat: Text.RichText
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }
}
