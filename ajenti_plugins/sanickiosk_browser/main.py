from ajenti.api import *
from ajenti.plugins.main.api import SectionPlugin
from ajenti.ui import on
from ajenti.ui.binder import Binder

@plugin
class SanicKioskScreensaverPrefs (SectionPlugin):
	default_classconfig = {
		'home_url': 'http://sanickiosk.org',
		'kioskspeeddial': False,
		'kioskmode': True,
		'fullscreen': True,
		'browser_reset': True,
		'browser_idle': '2',
		'nokeys': False,
		'nocontextmenu': True,
		'nomenu': True,
		'nodownload': True,
		'noprint': True,
		'nomaillinks': True,
		'disable_config_url': True,
		'empty_on_exit': True,
		'accept_cookies_session_only': True,
		'hide_toolbar': False,
		'hide_home': False,
		'hide_back': False,
		'hide_forward': False,
		'hide_reload': False,
		'hide_addressbar': False,
		'hide_find': False,
		'hide_zoom': False,
		'hide_ppreview': True,
		'hide_print': True,
		'hide_reset': False,
		'custom_user_agent': '',
	}
	classconfig_root = True

	def init(self):
		self.title = 'Browser'
		self.icon = 'globe'
		self.category = 'SanicKiosk'

		self.append(self.ui.inflate('sanickiosk_browser:main'))
		self.binder = Binder(self, self)
		self.binder.populate()

	@on('save', 'click')
	def save(self):
		self.binder.update()
		self.save_classconfig()
		self.context.notify('info', _('Saved. Please restart SanicKiosk for changes to take effect.'))
		self.binder.populate()

		all_vars = '\n'.join([k + '="' + str(v) + '"' for k,v in self.classconfig.iteritems()])
		open('/home/sanickiosk/sanickiosk/config/browser.cfg', 'w').write(all_vars) #save

#	@on('speeddial_edit', 'click')
#	def speeddial_edit(self):
#		self.context.launch('notepad', path='/home/sanickiosk/sanickiosk/.firefox/speeddial.sav')

#	@on('filters_edit', 'click')
#	def filters_edit(self):
#		self.context.launch('notepad', path='/home/sanickiosk/sanickiosk/.firefox/urlfilter.ini')
