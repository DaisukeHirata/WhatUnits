# coding: utf-8

import glob
import os
import shutil

if __name__ == '__main__':

    files = glob.glob('./image/*')

    photo_id = 12740612945
    secret   = 9784351709

    for fi in files:
        photo_id = photo_id + 1
        secret = secret + 1
        print photo_id, secret
        thumb = str(photo_id) + '_s.jpg'
        large = str(photo_id) + '_b.jpg'
        os.rename(fi , thumb)
        shutil.copyfile(thumb, large)
