# coding: utf-8
import json

from model.ConversionMeasure import ConversionMeasure
from model.ConversionClass import ConversionClass
from model.ConversionUnit import ConversionUnit
from model.Owner import Owner
from model.SharingComment import SharingComment

class RestAPI:
    '''
    # RestAPI で クライアントに返すjsonデータを作成する。
    '''

    class APIKeyIsInvalid(Exception): pass
    class APIInvalidFormat(Exception): pass

    def __init__(self, api_key):
        if not self._check_api_key(api_key):
            raise APIKeyIsInvalid('Invalid API Key (Key has invalid format)')


    def units(self, method, extras, _format):
        '''
        #
        # Read the AGI environment variables sent from Asterisk to the script
        # at startup.  The input looks like:
        #     agi_request: example1.py
        #     agi_channel: SIP/000FF2266EE4-00000009
        #
        # After this bit of code you will be able to retrieve this information as:
        #     asterisk_env['agi_request']
        #     asterisk_env['agi_channel']
        #
        '''


        units = {}

        if extras:
            extras_list = extras.split(',')

        if _format == 'json':

            unit_records = ConversionUnit.objects.values()
            unit = []
            for rec in unit_records:
                rec['dateupload']   = rec['dateupload'].strftime('%s')
                rec['server']       = '2845'
                rec['id']           = rec['photo_id']
                rec['ownername']    = Owner.objects.get(id=rec['owner_id']).name
                rec['class']        = ConversionClass.objects.get(id=rec['class_id']).name
                measure = ConversionMeasure.objects.get(id=rec['measure_id'])
                rec['measure']      = measure.name
                rec['measureratio'] = measure.ratio
                del rec['photo_id']
                del rec['class_id']
                del rec['measure_id']
                del rec['created_user']
                del rec['modified_user']
                del rec['created_datetime']
                del rec['modified_datetime']
                unit.append(rec)

            units_inside = { 'page' : 1,
                             'total': len(unit_records),
                             'unit' : unit }

            units['units'] = units_inside

        else:
            raise APIInvalidFormat()

        return json.dumps(units, ensure_ascii=False)



    def share_comment(self, _format):

        share_comments = {}

        if _format == 'json':

            comment_records = SharingComment.objects.values()
            comment = []
            for rec in comment_records:
                rec['dateupload']   = rec['created_datetime'].strftime('%s')
                rec['id']           = str(rec['id'])
                rec['photo_id']     = rec['photo_id']
                rec['ownername']    = Owner.objects.get(id=rec['owner_id']).name
                rec['measure']      = rec['measure_name']
                rec['class']        = ConversionClass.objects.get(id=rec['class_id']).name
                rec['unit_title']   = ConversionUnit.objects.get(id=rec['unit_id']).title
                # remove unnecessary item
                del rec['class_id']
                del rec['measure_id']
                del rec['unit_id']
                del rec['created_user']
                del rec['modified_user']
                del rec['created_datetime']
                del rec['modified_datetime']
                comment.append(rec)

            comments_inside = { 'page'    : 1,
                                'total'   : len(comment_records),
                                'comment' : comment }

            share_comments['comments'] = comments_inside

        else:
            raise APIInvalidFormat()


        return json.dumps(share_comments, ensure_ascii=False)



    def _check_api_key(self, api_key):
        '''
        ToDo API Keyが正しいものが正規のものかチェックする
             不正場合、False
        '''
        return True
