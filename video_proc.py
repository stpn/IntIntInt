import os
import sys
import shutil
import smtplib
import csv
from threading import Thread


# make sure that these directories exist
# William Holloway: 10.161.80.215 is the media fac mac
#base dir - change this to where media is
# media_dir='/Volumes/media'
media_dir='/Volumes/My_Passport/Intel/Intel_Server/IntIntInt_front/public/videos2'

media_dir2='/Users/stepanboltalin/Documents/Vimeo_awards'

preprocessing_dir = media_dir2+'/preprocessing'
processing_dir = media_dir2+'/processing'
processed_orig_dir = media_dir2+'/processed_avis'




epiphan_dir = media_dir
audio_dir = '/Users/stepanboltalin/Documents/Vimeo_awards/audio'
audio_preprocessing_dir = audio_dir+'/audio_preprocessing'
audio_processing_dir = audio_dir+'/audio_processing'
audio_processed_orig_dir = audio_dir+'/processed_audio'
processed_dir = '/Users/stepanboltalin/Documents/Vimeo_awards/processed_audio_mp4'
valid_exts = ['.mp3']


def read_dict(thefile):
	result = []
	the_file = open(thefile)
	reader = csv.DictReader(the_file, delimiter=',')
	for row in reader:
		result.append(row)
	return result

class convert(Thread):
	def __init__ (self,ip):
		Thread.__init__(self)
		self.file = file
		self.status = -1
	def run(self):
		try:
#			print 'file is:  '+os.path.join(preprocessing_dir, self.file)
			#prep the name
			newfilename = self.file.replace('.avi','.m4v')
			#execute handbrake
			tc = ""
			for dic in read_dict('vid_dl_tc.csv'):
				if dic['video'] == self.file:
					tc = dic['timecode'].split()
			i = int
			i = 0
			print len(tc)
			for timec in tc:
			#            os.popen('/Volumes/media/scripts/HandBrakeCLI  --preset="iPhone & iPod Touch" --crop 0:0:0:0 -i '+os.path.join(preprocessing_dir, filen)+' -o '+os.path.join(processing_dir, newfilename),"r")
					os.popen('/usr/local/bin/ffmpeg -i ' +os.path.join(preprocessing_dir, self.file)+' -acodec copy -ss ' +timec+' -t 00:00:15 '+ os.path.join(processing_dir, file+'.mp4'),'r')
			#Add Intro clip
			#os.popen('/Volumes/media/QTCoffee/bin/catmovie /Volumes/media/stock_files/Introduction.m4v INPUTFILENAME.m4v -o INPUTFILENAME.m4v')
			#move the new .m4v
#			shutil.move(os.path.join(processing_dir, newfilename), os.path.join(processed_dir, newfilename))
			#move the original AVI
#			shutil.move(os.path.join(preprocessing_dir, self.file), os.path.join(processed_orig_dir, self.file))
			#rsync the file to MediaFacilities
#			cmd = 'rsync -av --exclude=".*" ' + os.path.join(processed_dir, newfilename) + ' 10.161.80.215::hollywoodsync'
			#This sends up the original avi file
			#cmd = 'rsync -av --exclude=".*" ' + os.path.join(processed_orig_dir, self.file) + ' 10.161.80.215::hollywoodsync'
		except Exception as e:
			print ""
			
for file in os.listdir(epiphan_dir):

	ext = os.path.splitext(file)[1]
#	print ext == valid_exts
#	if ext == valid_exts:
#		try:
	
	src_file = os.path.join(epiphan_dir, file)
	dst_file = os.path.join(preprocessing_dir, file)
#	print 'processing ' + src_file
	shutil.copy(src_file, dst_file)
	current = convert(dst_file)
	current.start()
