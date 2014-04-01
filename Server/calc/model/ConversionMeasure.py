# -*- coding: utf-8 -*-
'''
コンバージョンベーステーブルモデル
'''
__author__ = "Daisuke Hirata"
__date__   = "2014/2/23"


from django.db import models
from BaseModel import BaseModel

class ConversionMeasure(BaseModel):
    '''
    table model
        ConversionMeasure
    '''

    id                          = models.AutoField(primary_key=True)
    name                        = models.CharField(max_length=50)
    class_id                    = models.IntegerField()
    ratio                       = models.CharField(max_length=100)

    class Meta:
        db_table = "ConversionMeasure"
