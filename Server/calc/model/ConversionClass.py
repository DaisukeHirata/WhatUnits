# -*- coding: utf-8 -*-
'''
クラステーブルモデル
何の単位かを表す。
'''
__author__ = "Daisuke Hirata"
__date__   = "2014/2/23"

from django.db import models
from BaseModel import BaseModel

class ConversionClass(BaseModel):
    '''
    table model
        ConversionClass
    '''

    id                          = models.AutoField(primary_key=True)
    name                        = models.CharField(max_length=50)
    description                 = models.CharField(max_length=50)

    class Meta:
        db_table = "ConversionClass"
