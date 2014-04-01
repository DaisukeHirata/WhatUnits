# -*- coding: utf-8 -*-
'''
ベースモデル
'''
__author__ = "Daisuke Hirata"
__date__   = "2014/2/23"


from django.db import models


class BaseModel(models.Model):
    '''
    column:
        created_datetime                    # datetime(auto)
        modified_datetime                   # datetime(auto)
        created_user                        # charfield(30)
        modified_user                       # charfield(30)

    '''
    # レコードの作成日時、更新日時、作成ユーザー、更新ユーザー
    created_datetime  = models.DateTimeField(auto_now_add=True)
    modified_datetime = models.DateTimeField(auto_now=True)
    created_user      = models.CharField(max_length=50, null=True, blank=True)
    modified_user     = models.CharField(max_length=50, null=True, blank=True)

    def __unicode__(self):
        sb = [ "{key}='{value}'".format(key=key, value=self.__dict__[key])
                for key in self.__dict__ if key != '_state']
        return ', '.join(sb)


    class Meta:
        abstract = True

