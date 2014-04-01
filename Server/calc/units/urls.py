from django.conf.urls import patterns, include, url
import views

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^rest$', 'units.views.rest', name='rest'),
    url(r'^share-comment$', 'units.views.share_comment', name='share_comment'),
)
