from django.http import HttpResponse
from django.http import HttpResponseBadRequest
from django.http import HttpResponseForbidden
from django.http import HttpResponseNotAllowed

from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.cache import never_cache
from django.core.files.storage import FileSystemStorage

import uuid
import os

from restapi import RestAPI
from model.ConversionUnit import ConversionUnit
from model.ConversionMeasure import ConversionMeasure
from model.ConversionClass import ConversionClass
from model.SharingComment import SharingComment


@csrf_exempt
@never_cache
def rest(request):
    '''
    # restful api
    # get ConversionUnits json
    # post unit data(image and other attributes)
    '''
    response = None

    if request.method == 'GET':

        method  = request.GET.get('method', 'units.search')
        extras  = request.GET.get('extras', None)
        _format = request.GET.get('format', 'json')
        api_key = request.GET.get('api_key', None)

        try:
            restapi = RestAPI(api_key)
            result = restapi.units(method, extras, _format)
            response = HttpResponse(result, mimetype="application/json;charset=utf-8")
        except Exception, e:
            response = HttpResponseForbidden('failed to get units info %s' % e)

    elif request.method == 'POST':

        try:
            IMAGE_PATH = './static/image/'
            storage = FileSystemStorage(location=IMAGE_PATH)

            #import ipdb
            #ipdb.set_trace()

            thumbnail   = request.FILES['thumbnail_image']
            if os.path.exists(IMAGE_PATH+thumbnail.name):
                os.remove(IMAGE_PATH+thumbnail.name)
            thumbnailname = storage.save(None, thumbnail)
            thumbnailurl = storage.url(thumbnailname)

            large_image = request.FILES['large_image']
            if os.path.exists(IMAGE_PATH + large_image.name):
                os.remove(IMAGE_PATH + large_image.name)
            large_image_name = storage.save(None, large_image)
            large_image_url  = storage.url(large_image_name)

            print request.POST.get('photo_id')
            print request.POST.get('title')
            print request.POST.get('description')
            print request.POST.get('value')
            print request.POST.get('latitude')
            print request.POST.get('longitude')
            print request.POST.get('measure')
            measurename = request.POST.get('measure')
            classname = request.POST.get('classname')
            convclass = ConversionClass.objects.get(name=classname)
            measure = ConversionMeasure.objects.get(name=measurename, class_id=convclass.id)

            if ConversionUnit.objects.filter(photo_id=request.POST.get('photo_id')).count():
                unit = ConversionUnit.objects.get(photo_id=request.POST.get('photo_id'))
                unit.title        = request.POST.get('title')
                unit.description  = request.POST.get('description')
                unit.value        = request.POST.get('value')
                unit.latitude     = request.POST.get('latitude')
                unit.longitude    = request.POST.get('longitude')
                unit.measure_id   = measure.id
                unit.class_id     = measure.class_id
                unit.save()
            else:
                ConversionUnit(photo_id=request.POST.get('photo_id'),
                               title=request.POST.get('title'),
                               description=request.POST.get('description'),
                               value=request.POST.get('value'),
                               secret=str(uuid.uuid4()),
                               latitude=request.POST.get('latitude'),
                               longitude=request.POST.get('longitude'),
                               originalformat='jpg',
                               owner_id=100,
                               ispublic=True,
                               measure_id=measure.id,
                               class_id=measure.class_id).save()
            response = HttpResponse()
        except Exception, e:
            response = HttpResponseForbidden('failed to upload photo %s' % e)

    else:
        response = HttpResponseNotAllowed(['GET','POST'])

    return response


@csrf_exempt
@never_cache
def share_comment(request):
    '''
    restful api
    post share conversion result(image and other attributes)
    '''
    response = None

    if request.method == 'GET':

        #method  = request.GET.get('method', 'units.search')
        #extras  = request.GET.get('extras', None)
        _format = request.GET.get('format', 'json')
        api_key = request.GET.get('api_key', None)

        try:
            restapi = RestAPI(api_key)
            result = restapi.share_comment(_format)
            response = HttpResponse(result, mimetype="application/json;charset=utf-8")
        except Exception, e:
            response = HttpResponseForbidden('failed to get sharing comments %s' % e)

    elif request.method == 'POST':

        try:
            import ipdb
            ipdb.set_trace()

            IMAGE_PATH = './static/sharing_image/'
            storage = FileSystemStorage(location=IMAGE_PATH)

            thumbnail   = request.FILES['thumbnail_image']
            if os.path.exists(IMAGE_PATH+thumbnail.name):
                os.remove(IMAGE_PATH+thumbnail.name)
            thumbnailname = storage.save(None, thumbnail)
            thumbnailurl  = storage.url(thumbnailname)

            print request.POST.get('photo_id')
            print request.POST.get('source_value')
            print request.POST.get('converted_value')
            print request.POST.get('comment')
            print request.POST.get('measure')

            photo_id   = request.POST.get('photo_id')
            unit       = ConversionUnit.objects.get(photo_id=photo_id)

            SharingComment(photo_id         = request.POST.get('photo_id'),
                           source_value     = request.POST.get('source_value'),
                           converted_value  = request.POST.get('converted_value'),
                           comment          = request.POST.get('comment'),
                           measure_name     = request.POST.get('measure'),
                           originalformat   = 'jpg',
                           owner_id         = 100,
                           ispublic         = True,
                           measure_id       = unit.measure_id,
                           class_id         = unit.class_id,
                           unit_id          = unit.id).save()
            response = HttpResponse()
        except Exception, e:
            response = HttpResponseForbidden('failed to upload a sharing comment%s' % e)

    else:
        response = HttpResponseNotAllowed(['GET', 'POST'])

    return response

