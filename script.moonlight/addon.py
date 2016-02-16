import os
import sys
import urllib
import urlparse
import xbmcgui
import xbmcplugin
import xbmcaddon
import re
import subprocess

my_addon = xbmcaddon.Addon()
my_env = os.environ.copy()
my_env["LD_LIBRARY_PATH"] = my_addon.getAddonInfo("path")+"/libs:" + my_env["LD_LIBRARY_PATH"]

base_url = sys.argv[0]
addon_handle = int(sys.argv[1])
args = urlparse.parse_qs(sys.argv[2][1:])

xbmcplugin.setContent(addon_handle, 'files')

def build_url(query):
    return base_url + '?' + urllib.urlencode(query)

mode = args.get('mode', None)

if mode is None:
	xbmcplugin.addDirectoryItem(handle=addon_handle,
								url=build_url({'mode': 'pair'}),
								listitem=xbmcgui.ListItem('Pair'),
								isFolder=False)
	
	xbmcplugin.addDirectoryItem(handle=addon_handle,
								url=build_url({'mode': 'list'}),
								listitem=xbmcgui.ListItem('List Games'),
								isFolder=True)
	
	xbmcplugin.addDirectoryItem(handle=addon_handle,
								url=build_url({'mode': 'stream', 'app': ''}),
								listitem=xbmcgui.ListItem('Stream Default'),
								isFolder=False)
	xbmcplugin.endOfDirectory(addon_handle)
elif mode[0] == "pair":
	pair_args = ["pair"]
	if my_addon.getSetting("MOON_SERVER_IP") != "0.0.0.0":
		pair_args += [my_addon.getSetting("MOON_SERVER_IP")]
	
	p = subprocess.Popen([my_addon.getAddonInfo("path") + "/bin/moonlight"] + pair_args, stdout=subprocess.PIPE, env=my_env)
	pin = ""
	
	while True:
		l = p.stdout.readline()
		if "following PIN" in l:
			m = re.search(':\s(\d+)', l)
			pin = m.group(0)
			break
	
	dialog = xbmcgui.Dialog()
	dialog.ok("PIN code", "Insert the pin code in server: %s" % pin)
	
	ret = ''.join(p.stdout.readlines())
	
	if "Succesfully paired" in ret:
		dialog = xbmcgui.Dialog()
		dialog.ok("Paired", "Succesfully paired")
	else:
		dialog = xbmcgui.Dialog()
		dialog.ok("Error", "Failed to pair to server")
elif mode[0] == "list":
	list_args = ["list"]
	if my_addon.getSetting("MOON_SERVER_IP") != "0.0.0.0":
		list_args += [my_addon.getSetting("MOON_SERVER_IP")]
	p = subprocess.Popen([my_addon.getAddonInfo("path") + "/bin/moonlight"] + list_args, stdout=subprocess.PIPE, env=my_env)
	
	ret = ''.join(p.stdout.readlines()).strip()
	m = re.findall(r"\d.\s(.*?)\n|$", ret)
	
	for game in list(m):
		name = game.strip()
		if name != "":
			xbmcplugin.addDirectoryItem(handle=addon_handle,
								url=build_url({'mode': 'stream', 'app': name}),
								listitem=xbmcgui.ListItem(name),
								isFolder=False)
	xbmcplugin.endOfDirectory(addon_handle)
elif mode[0] == "stream":
	app = args.get('app', None)
	with open(my_addon.getAddonInfo("path") + '/start_moonlight.tmp', 'w') as f:
		if app is None:
			f.write("")
		else:
			f.write(app[0])
