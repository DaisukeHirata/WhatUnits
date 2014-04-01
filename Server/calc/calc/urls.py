from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^units/', include('units.urls')),
    url(r'^whatunits/services/', include('units.urls'))
)
