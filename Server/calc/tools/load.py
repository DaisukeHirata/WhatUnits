# coding: utf-8

import os
import glob

from model.ConversionClass import ConversionClass
from model.ConversionMeasure import ConversionMeasure
from model.ConversionUnit import ConversionUnit
from django.utils import timezone

def print_filelist():
    files = glob.glob('./static/image/*')
    for f in files:
        root, ext = os.path.splitext(f)
        ext = ext[1:]
        photo_id, secret, fmt= os.path.basename(root).split('_')
        print photo_id,
        print secret,
        print fmt,
        print ext


def regist_class():
    ConversionClass.objects.all().delete()
    ConversionClass(name='Height', description='高さ').save()
    ConversionClass(name='Distance', description='距離／長さ').save()
    ConversionClass(name='Weight', description='重さ').save()
    ConversionClass(name='Area', description='面積').save()
    ConversionClass(name='Volume', description='体積').save()
    ConversionClass(name='Money', description='金額').save()
    ConversionClass(name='Age', description='年齢').save()
    ConversionClass(name='Speed', description='速さ').save()
    ConversionClass(name='Sound Level', description='音量').save()
    regist_measure()
    regist_unit()

def regist_measure():
    ConversionMeasure.objects.all().delete()
    c = ConversionClass.objects.get(name='Height')
    ConversionMeasure(name='cm', class_id=c.id, ratio='0.01').save()
    ConversionMeasure(name='m',  class_id=c.id, ratio='1').save()
    ConversionMeasure(name='km', class_id=c.id, ratio='1000').save()
    c = ConversionClass.objects.get(name='Distance')
    ConversionMeasure(name='cm', class_id=c.id, ratio='0.01').save()
    ConversionMeasure(name='m',  class_id=c.id, ratio='1').save()
    ConversionMeasure(name='km', class_id=c.id, ratio='1000').save()
    ConversionMeasure(name='mm', class_id=c.id, ratio='0.001').save()
    c = ConversionClass.objects.get(name='Weight')
    ConversionMeasure(name='g',   class_id=c.id, ratio='1').save()
    ConversionMeasure(name='kg',  class_id=c.id, ratio='1000').save()
    ConversionMeasure(name='ton', class_id=c.id, ratio='1000000').save()
    c = ConversionClass.objects.get(name='Area')
    ConversionMeasure(name='c㎡', class_id=c.id, ratio='0.0001').save()
    ConversionMeasure(name='㎡',  class_id=c.id, ratio='1').save()
    ConversionMeasure(name='k㎡', class_id=c.id, ratio='1000000').save()
    c = ConversionClass.objects.get(name='Volume')
    ConversionMeasure(name='c㎥', class_id=c.id, ratio='0.000001').save()
    ConversionMeasure(name='㎥',  class_id=c.id, ratio='1').save()
    ConversionMeasure(name='k㎥', class_id=c.id, ratio='1000000000').save()
    c = ConversionClass.objects.get(name='Money')
    ConversionMeasure(name='円', class_id=c.id, ratio='1').save()
    ConversionMeasure(name='万円', class_id=c.id, ratio='10000').save()
    ConversionMeasure(name='億円', class_id=c.id, ratio='100000000').save()
    ConversionMeasure(name='兆円', class_id=c.id, ratio='1000000000000').save()
    c = ConversionClass.objects.get(name='Age')
    ConversionMeasure(name='歳', class_id=c.id, ratio='1').save()
    c = ConversionClass.objects.get(name='Speed')
    ConversionMeasure(name='m/秒', class_id=c.id, ratio='1').save()
    ConversionMeasure(name='km/時', class_id=c.id, ratio='10000').save()
    c = ConversionClass.objects.get(name='Sound Level')
    ConversionMeasure(name='Db', class_id=c.id, ratio='1').save()


value=['1000', '500', '200', '0.5', '0.02', '1000000', '80', '0.12', '3.14']
def regist_unit():
    ConversionUnit.objects.all().delete()
    classes = {}
    for cname in ['Height', 'Distance', 'Weight', 'Area', 'Volume', 'Money', 'Age', 'Speed', 'Sound Level']:
        cl = ConversionClass.objects.get(name=cname)
        classes[cl.id] = ConversionMeasure.objects.filter(class_id=cl.id)
    cids = classes.keys()

    print cids

    files = glob.glob('./static/image/*')
    for i, f in enumerate(files):
        root, ext = os.path.splitext(f)
        ext = ext[1:]
        photo_id = os.path.basename(root).split('_')[0]
        cla_id = cids[i % len(cids)]
        mids = classes[cla_id]

        if ConversionUnit.objects.filter(photo_id=photo_id).count() == 0:
            ConversionUnit(
                    photo_id=str(photo_id),
                    class_id=cla_id,
                    measure_id=mids[i % len(mids)].id,
                    value=value[i% len(value)],
                    owner_id=1,
                    secret=str(photo_id),
                    title=photo_id,
                    ispublic=True,
                    originalformat=ext,
                    description=str(photo_id),
                    latitude=0.1,
                    longitude=0.1,
                    accuracy=16,
                    dateupload=timezone.now()).save()




