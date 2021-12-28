import sys	# for command line arguments
import os	# for directory scanning

def parse_and_write(r, w, address, ram_size):

	# write header
	w.write("WIDTH=8;\n")	
	w.write("DEPTH=" + str(ram_size) + ";\n")
	w.write("\n")
	w.write("ADDRESS_RADIX=HEX;\n")
	w.write("DATA_RADIX=HEX;\n")
	w.write("\n")
	w.write("CONTENT BEGIN\n")

	# initialize unused to 0
	if (address > 0):
		w.write("\t[0.." + "{:02X}".format(address-1) + "] : 00;\n")	

	while True:

		while (r.read(1) != ':'):	# skip to the first byte in the line
			pass

		for i in range(16):		# 16 is the amount of bytes in 1 line of the dump
			word = ""
			r.read(1)			# skip space
			word += r.read(2)	# read byte
			w.write("\t" + "{:04X}".format(address) + " : " + word + ";\n")	# write byte
			address += 1		# increment address
		
		if (address >= ram_size):	# reached end of ram size 
			w.write("END;\n") 
			break

		while (r.read(1) != '\n'):	# skip to next line
			pass

def start_parse(dump_path):

	with open(dump_path, "r") as f, open("../prg.mif", "w") as p, open("../chr.mif", "w") as c:

		# read iNES header, currently only finding number of prgrom banks
		while (f.read(1) != ':'):	
			pass
		while (f.read(1) != '0'):
			pass
		if (f.read(1) == '1'):
			start_addr = 0xC000
		else:
			start_addr = 0x8000
		while (f.read(1) != '\n'):
			pass

		parse_and_write(f, p, start_addr, 0x10000)	# write prg.mif
		print("prg success")
		parse_and_write(f, c, 0x0000, 0x2000)		# write chr.mif
		print("chr success")

def print_dumps():	# prints all of the available dumps
	print("available dumps: ", end="")
	for dump in os.scandir(r'dumps/'):
		entry = dump.path.replace("dumps/", "")
		entry = entry.replace("_dump.txt", "")
		print(entry + " ", end="")

def main():

	try:
		start_parse("dumps/" + sys.argv[1] + "_dump.txt")
	except IndexError: 			# catch no arguments
		print("ERR: dump not specified")
		print_dumps()
		return
	except FileNotFoundError:	# catch invalid argument
		print("ERR: can't find specified dump")
		print_dumps()
		return
	
if (__name__ == "__main__"):
	main()	
