from ajenti.api import *
from ajenti.plugins.main.api import SectionPlugin
from ajenti.ui import on
from ajenti.ui.binder import Binder

@plugin
class SanicKioskScreensaverPrefs (SectionPlugin):
	default_classconfig = {
		'xscreensaver_enable': True,
		'xscreensaver_idle': '0:01:30',
		'glslideshow_duration': '',
		'glslideshow_pan': '',
		'glslideshow_fade': '3',
		'glslideshow_zoom': '100',
		'glslideshow_clip': True,
	}
	classconfig_root = True

	def init(self):
		self.title = 'Screensaver'
		self.icon = 'picture'
		self.category = 'SanicKiosk'

		self.append(self.ui.inflate('sanickiosk_screensaver:main'))
		self.binder = Binder(self, self)
		self.binder.populate()

	@on('save', 'click')
	def save(self):
		self.binder.update()
		self.save_classconfig()
		self.context.notify('info', _('Saved. Please restart SanicKiosk for changes to take effect.'))
		self.binder.populate()

		all_vars = '\n'.join([k + '="' + str(v) + '"' for k,v in self.classconfig.iteritems()])
		open('sanickiosk/config/screensaver.cfg', 'w').write(all_vars) #save
