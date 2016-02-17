import xbmcplugin
import xbmcaddon
import xbmcgui
import xbmc

import random
import urllib
import urlparse
import sys
import os

from resources.moonlight import LibGameStream

base_url = sys.argv[0]
addon_handle = int(sys.argv[1])
args = urlparse.parse_qs(sys.argv[2][1:])
addon = xbmcaddon.Addon()
addon_base_path = xbmc.translatePath(addon.getAddonInfo('profile')).decode('utf-8')
xbmcplugin.setContent(addon_handle, "files")

def build_url(query):
    return base_url + "?" + urllib.urlencode(query)

def index():
    gs = LibGameStream(addon.getAddonInfo("path") + "/libs")
    
    address = addon.getSetting("MOON_SERVER_IP")
    if address == "0.0.0.0":
        address = gs.discover_server()
    
    if not gs.connect_server(address, os.path.join(addon_base_path, "keys")):
        dialog = xbmcgui.Dialog()
        dialog.ok("Error", "Failed connect to server (%s)" % (address))
        return
    
    if not gs.isPaired():
        pin = "%d%d%d%d" % (random.randint(0,9), random.randint(0,9), random.randint(0,9), random.randint(0,9))
        
        dialog = xbmcgui.Dialog()
        dialog.notification("PIN code", "Insert the pin code in server: %s" % pin, xbmcgui.NOTIFICATION_INFO, 10000)
        
        if gs.pair(pin):
            dialog = xbmcgui.Dialog()
            dialog.ok("Paired", "Succesfully paired")
        else:
            dialog = xbmcgui.Dialog()
            dialog.ok("Error", "Failed to pair to server, try again")
            return
    
    for appId, name in gs.applist():
        base_path = os.path.join(addon_base_path, "images")
        
        if not os.path.exists(base_path):
            os.makedirs(base_path)
        
        poster_path = os.path.join(base_path, str(appId) + ".png")
        
        if not os.path.isfile(poster_path):
            gs.poster(appId, base_path)
            xbmc.sleep(100)
        
        xbmcplugin.addDirectoryItem(handle=addon_handle, 
                                    url=build_url({"mode": "stream", "app": name}),
                                    listitem=xbmcgui.ListItem(label=name, thumbnailImage=poster_path),
                                    isFolder=False)
    
    xbmcplugin.endOfDirectory(addon_handle)

def stream(app = None):
    with open(addon.getAddonInfo("path") + "/start_moonlight.tmp", "w") as f:
        if app is None:
            f.write("")
        else:
            f.write(app[0])

mode = args.get("mode", None)
if mode is None:
    index()
elif mode[0] == "stream":
    app = args.get("app", None)
    stream(app)
