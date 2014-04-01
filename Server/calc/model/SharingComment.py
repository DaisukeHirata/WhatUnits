# -*- coding: utf-8 -*-
'''
Sharing comments model
'''
__author__ = "Daisuke Hirata"
__date__   = "2014/2/28"


from django.db import models
from BaseModel import BaseModel

class SharingComment(BaseModel):
    '''
    table model
        SharingComment
    '''
    id                          = models.AutoField(primary_key=True)
    photo_id                    = models.CharField(max_length=50)
    source_value                = models.CharField(max_length=100)
    converted_value             = models.CharField(max_length=100)
    comment                     = models.CharField(max_length=300)
    measure_name                = models.CharField(max_length=100)
    dateupload                  = models.DateTimeField(auto_now=True)
    ispublic                    = models.BooleanField()                   # not used yet
    originalformat              = models.CharField(max_length=20)         # jpg only now
    owner_id                    = models.IntegerField(null=True)          # not used yet
    class_id                    = models.IntegerField(null=True)          # FK
    measure_id                  = models.IntegerField(null=True)          # FK
    unit_id                     = models.IntegerField(null=True)          # FK

    class Meta:
        db_table = "SharingComment"
