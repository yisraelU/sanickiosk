from ajenti.api import *
from ajenti.plugins import *


info = PluginInfo(
	title='Browser',
	icon='globe',
	dependencies=[
		PluginDependency('main'),
        BinaryDependency('firefox'),
	],
)


def init():
	import main
