from ajenti.api import *
from ajenti.plugins import *


info = PluginInfo(
	title='Screensaver',
	icon='picture',
	dependencies=[
		PluginDependency('main'),
        BinaryDependency('xscreensaver'),
	],
)


def init():
	import main
