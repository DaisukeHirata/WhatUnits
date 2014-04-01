# -*- coding: utf-8 -*-
'''
ユニットテーブルモデル
'''
__author__ = "Daisuke Hirata"
__date__   = "2014/2/23"


from django.db import models
from BaseModel import BaseModel

class ConversionUnit(BaseModel):
    '''
    table model
        ConversionUnit
    '''

    id                          = models.AutoField(primary_key=True)
    photo_id                    = models.CharField(max_length=50)
    title                       = models.CharField(max_length=100)
    description                 = models.CharField(max_length=500)
    value                       = models.CharField(max_length=100)
    secret                      = models.CharField(max_length=50)
    ispublic                    = models.BooleanField()                 # not used yet
    originalformat              = models.CharField(max_length=20)       # jpg only now
    latitude                    = models.FloatField(null=True)
    longitude                   = models.FloatField(null=True)
    accuracy                    = models.IntegerField(null=True)
    dateupload                  = models.DateTimeField(auto_now=True)
    owner_id                    = models.IntegerField(null=True)        # not used yet
    class_id                    = models.IntegerField(null=True)        # FK
    measure_id                  = models.IntegerField(null=True)        # FK


    class Meta:
        db_table = "ConversionUnit"
