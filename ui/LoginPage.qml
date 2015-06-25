import QtQuick 2.0
import Ubuntu.Components 1.1
import QtQuick.LocalStorage 2.0
import Ubuntu.Web 0.2
import "../js/scripts.js" as Scripts
import "../js/URLQuery.js" as URLQuery

Page {
    id: webPage
    title: i18n.tr("Login")

    Item {
        anchors {
            margins: units.gu(2)
            fill: parent
        }

        WebView {
            id: webView

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height

            // zoomTo:
            property string client_id: "4944952"
            property string client_secret: "ez5WKrh60YHzIzK2guUg"

            // the redirect_uri can be any site
            property string redirect_uri: "https://oauth.vk.com/blank.html&display=touch&v=5.33&response_type=token"

            url: "https://oauth.vk.com/authorize?client_id="+client_id+"&scope=audio,status&redirect_uri="+redirect_uri

            onUrlChanged: {
                var urll = webView.url;
                urll = urll.toString();

                var result = URLQuery.parseParams(urll);
                var resat = result.access_token;
                var resuserid = result.user_id;

                if (!resat&&!result.error) {
                    //return;
                    //console.log('xeta')
                }
                else if(result.error) {
                    Qt.quit();
                    //console.log('xeta')
                }
                else {
                    Scripts.setKey('access_token', resat);
                    Scripts.setKey('user_id', resuserid);
                    home();
                }
            }
            onLoadingChanged: {
                if (webView.lastLoadFailed) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to authenticate to VK. Check your connection and firewall settings."), pageStack.pop)
                }
            }
        }

        UbuntuShape {
            anchors.centerIn: parent
            width: column.width + units.gu(4)
            height: column.height + units.gu(4)
            color: Qt.rgba(0.2,0.2,0.2,0.8)
            opacity: webView.loading ? 1 : 0

            Behavior on opacity {
                UbuntuNumberAnimation {
                    duration: UbuntuAnimation.SlowDuration
                }
            }
            Column {
                id: column
                anchors.centerIn: parent
                spacing: units.gu(1)

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    fontSize: "large"
                    text: webView.loading ? i18n.tr("Loading web page...")
                    : i18n.tr("Success!")
                }

                ProgressBar {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: units.gu(30)
                    maximumValue: 100
                    minimumValue: 0
                    value: webView.loadProgress
                }
            }
        }
    }
}

