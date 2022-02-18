#!/usr/bin/env python3

# Looking for variables
config = open('./configFAUST.h','r')
DATA_WIDTH = 0
for line in config:
	if line.lstrip().startswith('#define DATA_WIDTH'):
		DATA_WIDTH = line.split()[2]
		break
if DATA_WIDTH == '16':
	WS_RATIO='32'
elif DATA_WIDTH == '24':
	WS_RATIO='64'
elif DATA_WIDTH == '32':
	WS_RATIO='64'
else:
	print "[ERROR] Invalide DATA_WIDTH value in configFAUST.h: DATA_WIDTH=" + DATA_WIDTH
#input file
reading_file = open("./src/i2s_transceiver.vhd", "rt")

new_file_content = ""
new_generic = ""
is_inside_generic=False
for line in reading_file:
	if is_inside_generic:
		#Do nothing ,delete old line of generic
		if line.lstrip().startswith('port'):
			new_file_content += line #Keep the "port" line
			is_inside_generic=False
	elif line.lstrip().startswith('generic'): # The lstrip() method will remove leading whitespaces, newline and tab characters on a string beginning:
		is_inside_generic=True
		new_file_content += line #Keep the "generic" line
		# Write the generic bloc here
		new_generic += " -- AUTO GENERATED WITH vhdl_value_set.py file, DO NOT CHANGE ANYTHING HERE\n"
		new_generic += " --------------------------------------------------------------------------\n"
		new_generic += "	mclk_sclk_ratio : integer := 4; \n" 
		new_generic += "    sclk_ws_ratio   : integer := "+ WS_RATIO +"; \n"
		new_generic += "	d_width         : integer := "+ DATA_WIDTH +"); \n"
		new_generic += " --------------------------------------------------------------------------\n"
		new_generic += " -- END OF AUTO GENERATED\n"
		# end of generic bloc
		new_file_content += new_generic
	else:
		new_file_content += line
	
#close input file
reading_file.close()

writing_file = open("./src/i2s_transceiver.vhd", "wt")
writing_file.write(new_file_content)
writing_file.close()

