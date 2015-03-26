# Introduction #

The qt-google-maps example uses Google Maps API v3. To use API you need to register your own application on Google. Do not worry: the procedure is very simple.


# Details #

You need to login to Google, so first you need to create simple Google account. Then you can visit the page

**https://code.google.com/apis/console**

there you can create your application. You need to check access to **Google Maps API v3** in tab "Services".

Then you need create client ID in tab "API Access".

Then  you can see credentials of your application. You need to copy and paste **API key** to file **settings\_manager.cpp**. More exactly, you need to find string **YOUR\_API\_KEY\_HERE** in the **settings\_manager.cpp** and replace it to your **API key**.
```
SettingsManager::SettingsManager(QObject *parent) :
    QObject(parent)
{
    ...

    m_strApiKey = "YOUR_API_KEY_HERE";
}

```

After that you can compile and run qml-google-maps.