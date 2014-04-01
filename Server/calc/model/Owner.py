# -*- coding: utf-8 -*-
'''
オーナーテーブルモデル
'''
__date__    = "2014/2/23"


from django.db import models
from BaseModel import BaseModel

class Owner(BaseModel):
    '''
    table model
        Owner
    '''

    id                          = models.AutoField(primary_key=True)
    name                        = models.CharField(max_length=50)

    class Meta:
        db_table = "Owner"
