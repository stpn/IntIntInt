import csv

def read_dict(thefile):
	result = []
	source_file = open(thefile)
	reader = csv.DictReader(source_file, delimiter=',')
	for row in reader:
		d.append(row)
	return d 