#include "settings_manager.h"
#include <QSettings>
#include <QDebug>

SettingsManager::SettingsManager(QObject *parent) :
    QObject(parent)
{
    QSettings::setPath(QSettings::NativeFormat, QSettings::UserScope, "qml/qml-google-maps");
    QSettings settings(QSettings::UserScope, "ICS", "Maps Client");
    m_nZoom = settings.value("zoom", 15).toInt();
    m_strMapTypeId = settings.value("mapTypeId", "google.maps.MapTypeId.ROADMAP").toString();
    m_dLat = settings.value("lat", 55.75).toDouble();
    m_dLng = settings.value("lng", 37.6166667).toDouble();

    qDebug() << "SettingsManager::SettingsManager" << m_nZoom << m_strMapTypeId;

    m_strApiKey = "YOUR_API_KEY_HERE";
}

QVariant SettingsManager::zoom() const
{
    qDebug() << "SettingsManager::zoom()" << m_nZoom;
    return m_nZoom;
}

void SettingsManager::setZoom(const QVariant& zoom)
{
    qDebug() << "SettingsManager::setZoom()" << zoom;
    m_nZoom = zoom.toInt();
    QSettings settings(QSettings::UserScope, "ICS", "Maps Client");
    settings.setValue("zoom", m_nZoom);
}

QVariant SettingsManager::mapTypeId() const
{
    qDebug() << "SettingsManager::mapTypeId()" << m_strMapTypeId;
    return m_strMapTypeId;
}

void SettingsManager::setMapTypeId(const QVariant& id)
{
    qDebug() << "SettingsManager::setMapTypeId()" << id;
    m_strMapTypeId = id.toString();
    QSettings settings(QSettings::UserScope, "ICS", "Maps Client");
    settings.setValue("mapTypeId", m_strMapTypeId);
}

QVariant SettingsManager::lat() const
{
    return m_dLat;
}

void SettingsManager::setLat(const QVariant& lat)
{
    m_dLat = lat.toDouble();
    QSettings settings(QSettings::UserScope, "ICS", "Maps Client");
    settings.setValue("lat", m_dLat);
}

QVariant SettingsManager::lng() const
{
    return m_dLng;
}

void SettingsManager::setLng(const QVariant& lng)
{
    m_dLng = lng.toDouble();
    QSettings settings(QSettings::UserScope, "ICS", "Maps Client");
    settings.setValue("lng", m_dLng);
}


QVariant SettingsManager::htmlString() const
{
    if( m_strApiKey == "YOUR_API_KEY_HERE" ) {
        return "<html><body><h1 style=\"text-align: center; margin-top: 40px;\">Set your API KEY in code.</h1></body></html>";
    }

    QString str =
            "<!DOCTYPE html>"
            "<html>"
            "<head>"
            "<meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=no\" />"
            "<style type=\"text/css\">"
            "html { height: 100% }"
            "body { height: 100%; margin: 0; padding: 0 }"
            "#map_canvas { height: 100% }"
            "</style>"
            "<script type=\"text/javascript\""
            "src=\"http://maps.googleapis.com/maps/api/js?key=%5&sensor=false\">"
            "</script>"
            "<script type=\"text/javascript\">"
            "var map; "
            "var marker; "
            "function initialize() {"
            "var myOptions = {"
            "center: new google.maps.LatLng(%2, %3),"
            "zoom: %1,"
            "mapTypeId: %4,"
            "panControl: true,"
            "zoomControl: false,"
            "mapTypeControl: false,"
            "mapTypeControlOptions: {"
            "position: google.maps.ControlPosition.RIGHT_CENTER"
            "}"

            "};"
            "map = new google.maps.Map(document.getElementById(\"map_canvas\"), myOptions);"
            "}"
            "</script>"
            "</head>"
            "<body onload=\"initialize()\">"
            "<div id=\"map_canvas\" style=\"width:100%; height:100%\"></div>"
            "</body>"
            "</html>";
    str = str.arg(m_nZoom).arg(m_dLat).arg(m_dLng).arg(m_strMapTypeId).arg(m_strApiKey);
    return str;
}

void SettingsManager::setHtmlString(const QVariant&)
{

}
