import re
import sys
import nltk
import nltk.data
import string
import random

# do the replace_all : == 3 to == 3
poem_length = 10

anapest_sylb = 2
hip_hop_sylb = 3
#########TOOLS:#############

def uniq(seq, idfun=None): 
   # order preserving
   if idfun is None:
       def idfun(x): return x
   seen = {}
   result = []
   for item in seq:
       marker = idfun(item)
       # in old Python versions:
       # if seen.has_key(marker)
       # but in new ones:
       if marker in seen: continue
       seen[marker] = 1
       result.append(item)
   return result

###############ACTION:##########s
def create_dict():
    result = {'key':'value'}
    for line in open('stress_dict_no_the.txt','r').readlines():
        word = re.search("^.*?\s", line)
        values = re.search("\s(.*?$)", line)
        result[word.group().replace(' ','').lower()] = values.group().replace('  ','')
    return result


def populate_dict(dct):
    result = ""
    myfile = open('stress_dict.csv','w')
    for key, value in dct.items():
		result += key + ',' + value + '\n'		
    myfile.write(result)



def collect_preps():
	result = []
	string = open('preps.txt', 'r').read()
	result = string.split()
	return result

def read_poem(poem):
#    string = open(poem,'r').read()
    result = poem.split()
    return result

def parse_poem(poem, phono):
    arr = []
    for string in poem:
        for key in phono.keys():
            if string == key:
                arr2 = {'key':'value'}
                arr2[string] = phono[key]
                arr.append(arr2)
    return arr


def parse_poem_video2(poem, phono, preps):
	artc = ["a","an"]
	stress = 0
	wrd = ""
	result = {'key':{'key2':[]}}
	for dic in poem:
		phrase = dic['phrase'].split()
		for word in phrase:
			word = word.lower()
			if word not in preps:
				if word not in artc:
					for key in phono.keys():
						if word == key:
							sylb_ary = phono[key].split(' ')
							arr3 = []
							for val in sylb_ary:
								if len(val) == 3:
									arr3.append(val)
#							print 'ARR3 FOR ' + word + ' IS ' + " ".join(arr3)
							strs = False
							for val in arr3:
								if '1' in val:
									stress = arr3.index(val)+1
									strs = True
							if strs == False:
								stress = 0
#							print 'STRESS FOR ' + word + ' IS ' + str(stress)
							syllab = len(arr3)-stress
#							print 'SYLB FOR ' + word + ' IS ' + str(syllab)
							if stress <= 3:
								if syllab <= hip_hop_sylb:
									if stress not in result.keys():
										result[stress]={word:[syllab, dic['phrase_id']]}
									if word not in result[stress]:
										result[stress][word]=[syllab, dic['phrase_id']]
									if word in result[stress]:
										result[stress][word].append(dic['phrase_id'])
	del result['key']
	return result

def parse_poem_video(poem, phono):
    arr = []
    for dic in poem:
		phrase = dic['phrase'].split()
		for string in phrase:
			for key in phono.keys():
				if string.lower() == key:
					arr2 = {}
					arr2['word']=string.lower()
					arr2['phono']= phono[key]
					arr2['phrase_id'] = dic['phrase_id']
					arr.append(arr2)
    return arr


def parse_poem_multi(poem, phono):
    arr = []
    for string in poem:
	    b = []
	    for word in string.split():
	        for key in phono.keys():
	            if word == key:
	                arr2 = {}
	                arr2[word] = phono[key]
	                b.append(arr2)
	    arr.append(b)
    return arr

def pre_poem(arrr, preps):
	artc = ["the","a","an"]
	wrd = ""
	boole = False
	arr3 = []
	for poem_dict in arrr:
	    for key in poem_dict:
		    if key not in preps:
		        sylb = re.findall('..\d', poem_dict[key])
		        for string in sylb:
		            stress = re.search('..1', string)
		            if stress:
		                 arr = {}
		                 position = sylb.index(string)
		                 if boole == True:
		                     key = wrd + " " + key
		                     boole = False
		                 arr[key] = {position+2 : len(sylb) - (position+1)}
		                 arr3.append(arr)
		        if key in artc:
			        wrd = key
			        boole = True

	return arr3
	
def pre_poem_video(arrr, preps):
	artc = ["a","an"]
	wrd = ""
	boole = False
	arr3 = []
	for poem_dict in arrr:
		if poem_dict['word'] not in preps:
			arr = {}
			stress = 0
			sylb_ary = poem_dict['phono'].split(' ')
			for val in sylb_ary:
				if len(val) == 3:
					if '1' in val:
						stress = sylb_ary.index(val)+1
			sylb = len(sylb_ary)-stress
			if boole == True:
				arr['word'] = wrd + " " + poem_dict['word']
				arr['phono'] = {stress+1 : sylb}
				arr['phrase_id'] = poem_dict['phrase_id']
				arr3.append(arr)
				boole = False
		else:
			arr['word'] = wrd + " " + poem_dict['word']
			arr['phono'] = {stress : sylb}
			arr['phrase_id'] = poem_dict['phrase_id']
			arr3.append(arr)
			# for string in sylb:
			# 	stress = re.search('..1', string)
			# 	if stress:
			# 		arr = {}
			# 		position = sylb.index(string)
			# 		if boole == True:
			# 			arr['word'] = wrd + " " + poem_dict['word']
			# 			arr['phono'] = {position+2 : len(sylb) - (position+1)}
			# 			arr['phrase_id'] = poem_dict['phrase_id']
			# 			arr3.append(arr)
			# 			boole = False
			# 		else:
			# 			arr['word'] = poem_dict['word']
			# 			arr['phono'] = {position+2 : len(sylb) - (position+1)}
			# 			arr['phrase_id'] = poem_dict['phrase_id']
			# 			arr3.append(arr)
		if poem_dict['word'] in artc:
			wrd = poem_dict['word']
			boole = True
	return arr3


####

def pre_poem_no_preps(arrr):
	wrd = ""
	boole = False
	arr3 = []
	for poem_dict in arrr:
	    for key in poem_dict:
	        syllabuses = re.findall('\d\s', poem_dict[key])
	        sylb = re.findall('..\d', poem_dict[key])
	        for string in sylb:
	            stress = re.search('..1', string)
	            if stress:
	                 arr = {}
	                 position = sylb.index(string)
	                 if boole == True:
	                     key = wrd + " " + key
	                     boole = False
	                 arr[key] = {position+2 : len(sylb) - (position+1)}
	                 arr3.append(arr)
		        
	return arr3 


def pre_poem_multi(arrr):
	wrd = ""
	boole = False

	arr3 = []
	for phrase in arrr:
		arr4 = []
		for poem_dict in phrase:
		    for key in poem_dict:
		        syllabuses = re.findall('\d\s', poem_dict[key])
		        sylb = re.findall('..\d', poem_dict[key])
		        for string in sylb:
		            stress = re.search('..1', string)
		            if stress:
		                 arr = {}
		                 position = sylb.index(string)
		                 if boole == True:
		                     key = wrd + " " + key
		                     boole = False
		                 arr[key] = {position+2 : len(sylb) - (position+1)}
		                 arr4.append(arr)
		arr3.append(arr4)

	return arr3 



def clean_dict(arr):
	for dct in arr:  
		i+=1
		for k in dct.keys():
			if dct[k] == 'value':
				del dct[k]
	return arr
	
def clean_dict_none(arr):
	print arr
	arrr = []
	for dct in arr:
		for k in dct.keys():
			if k == 'phrase':
				if len(dct[k]) == 0:
					print arr[arr.index(dct)]
					arrr.append(dct)
	for n in arrr:
		arr.remove(n)
	return arr

def shallow_clean_dict(dct):
	for k in dct.keys():
		if dct[k] == 'value':
			del dct[k]
	return dct

def dupl_arr(dct):
	arr = []
	for key in dct:
		arr.append(key)
	return arr


def byronize_video(wordz, metre):
	single = {1 : 0}
	result = []
	arr2 = []
	tmp_word = ""
	strs1 = 0
	slbs1 = 1
	slbs = 1
	strs2 = 10
	slbs2 = 10
	i = 0
	boole = True
	meter = 0
	for words in wordz:
		temp = words
		word = words['word']
		print "WORD1 IS: "+word
		values = words['phono']
		for stress, syllab in values.items():
			if slbs2 <10:
				ab = slbs2+stress
				if ab != 3:
					boole = False
				else:
					boole = True
			strs1 = stress
			slbs1 = syllab
			tmp_word = word
			if i<(len(wordz)-1):
			    i+=1								
		if boole == True:
			word2 = wordz[i]['word']
			value2 = wordz[i]['phono']
			print "WORD2 IS: "+word2
			if value2 == single:
				for stress2, syllab2 in value2.items():
					if syllab2 == 3:
						if word2 != tmp_word:
							if tmp_word not in arr2:
								if word2 not in arr2:
									b =  slbs1 + stress2
									if b == 3:
										arr = {}
										arr3 = {}	
										slbs2 = syllab2
										meter+=1
										if meter == metre:
											word2 = word2
											meter = 0
										arr['word'] = word
										arr['phrase_id'] = words['phrase_id']
										arr3['word'] = word2
										arr3['phrase_id'] = wordz[i]['phrase_id']
										arr2.append(word)
										arr2.append(word2)
										result.append(arr)
										result.append(arr3)
										break
			else:
				for stress2, syllab2 in value2.items():
					if word2 != tmp_word:
						if tmp_word not in arr2:
							if word2 not in arr2:
								b =  slbs1 + stress2
								if b == 3:
									arr = {}
									arr3 = {}	
									slbs2 = syllab2
									meter+=1
									if meter == metre:
										word2 = word2
										meter = 0
									arr['word'] = word
									arr['phrase_id'] = words['phrase_id']
									arr3['word'] = word2
									arr3['phrase_id'] = wordz[i]['phrase_id']
									arr2.append(word)
									arr2.append(word2)
									result.append(arr)
									result.append(arr3)
									break
	return result

def pick_random_word(wordz, stress):
	random_word = random.choice(wordz[stress].keys())
	return random_word

def find_syllab_3(wordz):
	result = []
	for stress, words in wordz.iteritems():
		for word in words.keys():
			if words[word][0] == 3:
				result.append([stress, word])
	return result

def pick_random_phrase(wordz, stress, word):
#	print 'WORD_R is '+ word
	length = len(wordz[stress][word])
	rand = random.randint(1,length-1)
	random_phrase = wordz[stress][word][rand]
	wordz[stress][word]
	return random_phrase




def byronize_video2(wordz, metre):
# result = {stress: {word:[syllab, phrase_id]}}
	big_meter = 0
	arr3 = []
	result = []
	word2 = ''
	syllab2 = 0
	meter = 0
	syllab_3_ary = find_syllab_3(wordz)
	stress = 3
	stress2 = 0
	boole = True
	word1 = pick_random_word(wordz, 3)
	syllab = wordz[stress][word1][0]
	arr3.append(word1)	
	for n in range(poem_length):
#		if big_meter == 30:
#			break
		arr3.append(word2)
		for strs in wordz.keys():
			arr1 = {}
			arr2 = {}
			stress2 = strs
			if syllab+stress2 == 3:
				print 'start of the loop'
				word2 = pick_random_word(wordz, stress2)
				print 'WORD2 IS ' + word2
				syllab2 = wordz[stress2][word2][0]
				if syllab == 0:
					if stress == 1:
						print 'SINGLE!'
						stress2 = 3
						word2 = pick_random_word(wordz, stress2)
						syllab2 = wordz[stress2][word2][0]
				# print 'STRESS1 is '+ str(stress)
				# print 'WORD1 IS ' + word1
				# print 'SYLLAB2 IS ' + str(syllab2)
				# print 'STRESS2 is '+ str(stress2)
				# print 'WORD2 IS ' + word2
				if boole == True:
					arr1['word'] = word1
					arr1['phrase_id'] = pick_random_phrase(wordz, stress, word1)
					result.append(arr1)
					boole = False
				meter+=1
				if meter == metre:
					word2 = word2
					meter = 0
					big_meter +=1	
				arr2['word'] = word2
				arr2['phrase_id'] = pick_random_phrase(wordz, stress2, word2)
				result.append(arr2)
				word1 = word2
				stress = stress2
				syllab = syllab2
				break
	print arr3
	return result


def byronize_video_hiphop(wordz, metre):
# result = {stress: {word:[syllab, phrase_id]}}
	line =  0
	big_meter = 0
	arr3 = []
	result = []
	word2 = ''
	syllab2 = 0
	meter = 0
	syllab_3_ary = find_syllab_3(wordz)
	stress = 3
	stress2 = 0
	boole = True
	word1 = pick_random_word(wordz, 3)
	syllab = wordz[stress][word1][0]
	arr3.append(word1)	
	for n in range(poem_length):
#		if big_meter == 30:
#			break
		arr3.append(word2)
		for strs in wordz.keys():
			arr1 = {}
			arr2 = {}
			stress2 = strs
			if syllab+stress2 == 3:
				print 'start of the loop'
				word2 = pick_random_word(wordz, stress2)
				print 'WORD2 IS ' + word2
				syllab2 = wordz[stress2][word2][0]
				if syllab == 0:
					if stress == 1:
						print 'SINGLE!'
						stress2 = 3
						word2 = pick_random_word(wordz, stress2)
						syllab2 = wordz[stress2][word2][0]
				# print 'STRESS1 is '+ str(stress)
				# print 'WORD1 IS ' + word1
				# print 'SYLLAB2 IS ' + str(syllab2)
				# print 'STRESS2 is '+ str(stress2)
				# print 'WORD2 IS ' + word2
				if boole == True:
					arr1['word'] = word1
					arr1['phrase_id'] = pick_random_phrase(wordz, stress, word1)
					result.append(arr1)
					boole = False
				meter+=1
				if meter == metre:
					word2 = word2
					meter = 0
					big_meter +=1	
				arr2['word'] = word2
				arr2['phrase_id'] = pick_random_phrase(wordz, stress2, word2)
				result.append(arr2)
				word1 = word2
				stress = stress2
				syllab = syllab2
				break
	print arr3
	return result







####BYRONIZE_DICT
def byronize(wordz, metre):
	single = {1 : 0}
	arr2 = []
	tmp_word = ""
	strs1 = 0
	slbs1 = 1
	slbs = 1
	strs2 = 10
	slbs2 = 10
	i = 0
	boole = True
	meter = 0
	print wordz
	for words in wordz:
		temp = words
		for word, values in words.items():
			for stress, syllab in values.items():
				if slbs2 <10:
					ab = slbs2+stress
					if ab != 3:
						boole = False
					else:
						boole = True
				strs1 = stress
				slbs1 = syllab
				tmp_word = word
				if i<(len(wordz)-1):
				    i+=1								
		if boole == True:
			for word2, value2 in wordz[i].items():
				if value2 == single:
					for stress2, syllab2 in value2.items():
						if syllab2 == 3:
							if word2 != tmp_word:
								if tmp_word not in arr2:
									if word2 not in arr2:
										b =  slbs1 + stress2
										if b == 3:
											slbs2 = syllab2
											meter+=1
											if meter == metre:
												word2 = word2 + '\n'
												meter = 0
											arr2.append(word)
											arr2.append(word2)
											break
				else:
					for stress2, syllab2 in value2.items():
						if word2 != tmp_word:
							if tmp_word not in arr2:
								if word2 not in arr2:
									b =  slbs1 + stress2
									if b == 3:
										slbs2 = syllab2
										meter+=1
										if meter == metre:
											word2 = word2 + '\n'
											meter = 0
										arr2.append(word)
										arr2.append(word2)
										break
	return arr2


	
	
def byronize_small(wordz):
	single = {1 : 0}
	arr2 = []
	tmp_word = ""
	strs1 = 0
	slbs1 = 1
	slbs = 1
	strs2 = 10
	slbs2 = 10
	i = 0
	boole = True
	for words in wordz:
		temp = words
		for word, values in words.items():
			for stress, syllab in values.items():
				if slbs2 <10:
					ab = slbs2+stress
					if ab != 3:
						boole = False
					else:
						boole = True
				strs1 = stress
				slbs1 = syllab
				tmp_word = word
				if i<(len(wordz)-1):
				    i+=1								
		if boole == True:
			for word2, value2 in wordz[i].items():
				if value2 == single:
					for stress2, syllab2 in value2.items():
						if syllab2 == 3:
							if word2 != tmp_word:
								if tmp_word not in arr2:
									if word2 not in arr2:
										b =  slbs1 + stress2
										if b == 3:
											slbs2 = syllab2
											arr2.append(word)
											arr2.append(word2)
											return arr2
											
				else:
					for stress2, syllab2 in value2.items():
						if word2 != tmp_word:
							if tmp_word not in arr2:
								if word2 not in arr2:
									b =  slbs1 + stress2
									if b == 3:
										slbs2 = syllab2
										arr2.append(word)
										arr2.append(word2)
										return arr2
										
	


def byronize2(arr, variant):
	single_arr = arr['single']
	multi = arr['multi']
	verbs = arr['verbs']
	single = {1 : 0}
	arr3 = []
	tmp_word = ""
	strs1 = 0
	slbs1 = 1
	slbs = 1
	strs2 = 10
	slbs2 = 10 #this keeps track of last slbs
	orig_slbs = 10
	boole = True
	for wordz in multi:
		i = 0
		arr2 = []
		for words in wordz:
			temp = words
			for word, values in words.iteritems():
				for stress, syllab in values.iteritems():
					if slbs2 <10:
						ab = slbs2+stress
						if ab != 3:
							boole = False
						else:
							boole = True
					strs1 = stress
					slbs1 = syllab
					tmp_word = word
					if i<(len(wordz)-1):
					    i+=1
			if boole == True:
				for word2, value2 in wordz[i].iteritems():
					if value2 == single:
						for stress2, syllab2 in value2.iteritems():
							if syllab2 == 3:
								if word2 != tmp_word:
									if tmp_word not in arr2:
										if word2 not in arr2:
											b =  slbs1 + stress2
											if b == variant:
												slbs2 = syllab2
												arr2.append(word)
												arr2.append(word2)
												hsh = {word2:{stress2:syllab2}}
												verbs.insert(0,hsh)
												break
					else:
						for stress2, syllab2 in value2.iteritems():
							if word2 != tmp_word:
								if tmp_word not in arr2:
									if word2 not in arr2:
										b =  slbs1 + stress2
										if b == variant:
											slbs2 = syllab2
											arr2.append(word)
											arr2.append(word2)
											hsh = {word2:{stress2:syllab2}}
											verbs.insert(0,hsh)
											break
		if len(arr2)!=0:
			arr5 = byronize_small(verbs)
			verbs.pop(0)
			temp_word = {}
			for thing in verbs:
				for verb in thing.keys():
					if verb == arr5[1]:
						verbs.remove(thing)
						temp_word = thing
						break
			single_arr.insert(0,temp_word)
			arr6 = byronize_small(single_arr)
			single_arr.pop(0)
			for thing in single_arr:
				for noun in thing.keys():
					if noun == arr6[1]:
						single_arr.remove(thing)
						temp_word = thing
						break
			for w, vl in temp_word.items():
				for st, sl in vl.items():
					slbs2 = sl
			arr2.append(arr5[1])
			arr2.append(arr6[1])
			arr2 = " ".join(arr2)
			arr2 = arr2 + '\n'
			arr3.append(arr2)
	result = " ".join(arr3)		
	return result


###########POS############


# def parse_poem_video2(poem, phono, preps):
# 	artc = ["a","an"]
# 	stress = 0
# 	wrd = ""
# 	result = {'key':{'key2':[]}}
# 	for dic in poem:
# 		phrase = dic['phrase'].split()
# 		for word in phrase:
# 			word = word.lower()
# 			if word not in preps:
# 				if word not in artc:
# 					for key in phono.keys():
# 						if word == key:
# 							sylb_ary = phono[key].split(' ')
# 							arr3 = []
# 							for val in sylb_ary:
# 								if len(val) == 3:
# 									arr3.append(val)
# #							print 'ARR3 FOR ' + word + ' IS ' + " ".join(arr3)
# 							strs = False
# 							for val in arr3:
# 								if '1' in val:
# 									stress = arr3.index(val)+1
# 									strs = True
# 							if strs == False:
# 								stress = 0
# #							print 'STRESS FOR ' + word + ' IS ' + str(stress)
# 							syllab = len(arr3)-stress
# #							print 'SYLB FOR ' + word + ' IS ' + str(syllab)
# 							if stress <= 3:
# 								if syllab <= 2:
# 									if stress not in result.keys():
# 										result[stress]={word:[syllab, dic['phrase_id']]}
# 									if word not in result[stress]:
# 										result[stress][word]=[syllab, dic['phrase_id']]
# 									if word in result[stress]:
# 										result[stress][word].append(dic['phrase_id'])
# 	del result['key']
# 	return result

def pos_tag(poem):
	text = poem
	txt = re.sub('[%s]' % re.escape(string.punctuation), ' ', text)
	txt = re.sub('\n', ' ', txt)
	txt = re.sub('\s\s', ' ', txt)
	tagged = tagger.tag(txt.split(' '))
	return tagged

def pos_tag_video(poem):
	tagger = nltk.data.load("/taggers/treebank_ubt.pickle")
	i = 0
	for dic in poem:
		i+=1
		phrase = dic['phrase']
		phrase = re.findall(r'[\w.]+',phrase)
		tagged = tagger.tag(phrase)
		dic['phrase'] = tagged
	poem = clean_dict_none(poem)
	return poem


	
def chunk_poem(tagged):
	chunker = nltk.data.load("/chunkers/treebank_chunk_NaiveBayes.pickle")
	chunked = chunker.parse(tagged)
	return chunked


def chunk_poem_video(tagged):
	chunker = nltk.data.load("/chunkers/treebank_chunk_NaiveBayes.pickle")
	for dic in tagged:
		phrase = dic['phrase']
		chunked = chunker.parse(phrase)
		dic['phrase'] = chunked
	return tagged

def filter_insignificant(chunk, tag_suffixes=['DT', 'CC']):
  good = []
  for word, tag in chunk:
    ok = True
    for suffix in tag_suffixes:
      if tag.endswith(suffix):
        ok = False
        break
    if ok:
      good.append((word, tag))
  return good
	
def collect_nps(chunked):
	result = {}
	a = []
	b = []
	c = []
	for n in chunked:
	    if isinstance(n, nltk.tree.Tree):
			if n.node == 'NP':
				good = filter_insignificant(n)
#				for thing in n:
#					if thing[1] == 
				a.append(good)
				result['NP'] = a
	    if isinstance(n, tuple):
		    if (n[1] == 'VB') or (n[1] == 'VBD') or (n[1] == 'VBD') or (n[1] == 'VBG') or (n[1] == 'VBN') or (n[1] == 'VBP') or (n[1] == 'VBZ'):
				b.append(n)
				result['VERBS'] = b
	return result
	
def collect_nps_video(chunked):
	for dic in chunked:
		result = {}
		a = []
		b = []
		c = []
		for n in dic['phrase']:
			if isinstance(n, nltk.tree.Tree):
#				print n.__class__.__name__
				if n.node == 'NP':
					good = filter_insignificant(n)
					a.append(good)
					dic['NP'] = a
			if isinstance(n, tuple):
#				print 'KOOO'
				if (n[1] == 'VB') or (n[1] == 'VBD') or (n[1] == 'VBD') or (n[1] == 'VBG') or (n[1] == 'VBN') or (n[1] == 'VBP') or (n[1] == 'VBZ'):
					b.append(n)
					dic['VERBS'] = b
	print chunked
	return chunked

def make_nps(dct):
	result = {}
	multi = []
	single = []
	for category, contents in dct.items():
		if category == 'NP':
			for noun_phrase in contents:
				a = []
				for words in noun_phrase:
					a.append(words[0])
				if len(a) > 1:
					multi.append(' '.join(a))
					result['multiple'] = multi
				if len(a) == 1:
					if words[1] == 'NN':
						single.append(' '.join(a))
						result['single'] = single
	for key, value in result.items():
		uniq(value)
	return result


def make_nps_video(ary):
	for dct in ary:
		result = {}
		multi = []
		single = []
		for category in dct['phrase']:
		    if isinstance(category[0], nltk.tree.Tree):
				if category[0].node == 'NP':
					print 'boom'
					for noun_phrase in category[0]:
						a = []
						for words in noun_phrase:
							a.append(words[0])
						if len(a) > 1:
							multi.append(' '.join(a))
							dct['multiple'] = multi
						if len(a) == 1:
							if words[1] == 'NN':
								single.append(' '.join(a))
								dct['single'] = single
#	print ary
	return ary

def make_verbs(dct):
	result = []
	for category, contents in dct.items():
		if category == 'VERBS':
			for verb in contents:
				a = []
				a.append(verb[0])
				result.append(''.join(a))
	return result


def prepare_poem(nps, verbs):
	arr = {}
	preps = collect_preps()
	phonetics = create_dict()
	multi = parse_poem_multi(nps['multiple'], phonetics)
	single = clean_dict(parse_poem(nps['single'], phonetics))
	verbs = clean_dict(parse_poem(verbs, phonetics))
	verbs_dict = pre_poem(verbs, preps)
	single_dict = pre_poem_no_preps(single)
	multi_dict = pre_poem_multi(multi)
	arr['multi'] = multi_dict
	arr['single'] = single_dict
	arr['verbs'] = verbs_dict
	result = arr
	return result


#########################


def byronizer(poem):
	phonetics = create_dict()
	poem_text = read_poem(poem)
	preps = collect_preps()
	whoa = parse_poem(poem_text, phonetics)
	whoa = clean_dict(whoa)
	poem_dict = pre_poem(whoa, preps)
	poem_dict = clean_dict(poem_dict)
	metre = 4
#	myfile = open(poemname, 'w')
	brnsq = byronize(poem_dict, metre)
	i = 0
	for word in brnsq:
		i+=1
		if i == 8:
			word = word + '\n'
			i = 0
	brnsq= ' '.join(map(str,brnsq))
	return brnsq
#	myfile.write(brnsq)
#	myfile.close

def byronize_cfg(poem):
	variant = 4
	result = []
	posed = pos_tag(poem)
	chunked = chunk_poem(posed) 
	nps = collect_nps(chunked)
	nps_ary = make_nps(nps)
	vrb_ary = make_verbs(nps)
	arr = prepare_poem(nps_ary, vrb_ary)
	brnsq = byronize2(arr, variant)
	result = brnsq
	return result


def byronizer_video(poem):
	phonetics = create_dict()
	preps = collect_preps()
	poem_dict = parse_poem_video2(poem, phonetics, preps)
	metre = 3
	brnsq = byronize_video2(poem_dict, metre)
	return brnsq



def byronize_cfg_video(poem):
	variant = 4
	result = []
	posed = pos_tag_video(poem)
	chunked = chunk_poem_video(posed) 
	nps = collect_nps_video(chunked)
	#nps_ary = make_nps_video(nps)
	# vrb_ary = make_verbs(nps)
	# arr = prepare_poem(nps_ary, vrb_ary)
	# brnsq = byronize2(arr, variant)
	# result = brnsq
	return nps
#woo = byronize_pos(sys.argv[1], sys.argv[2])
# print woo

# woo2 = byronizer(sys.argv[1], sys.argv[2])	

####THIS LAUNCHES BYRONIZER1 FOR RAILS
#woo = byronizer(sys.argv[1])	
#print woo
