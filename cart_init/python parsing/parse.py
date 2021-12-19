def main():
	with open("dumps/smb_dump.txt", "r") as f, open("../prg.mif", "w") as p, open("../chr.mif", "w") as c:

		p.write("WIDTH=8;\n")
		p.write("DEPTH=65536;\n")
		p.write("\n")
		p.write("ADDRESS_RADIX=HEX;\n")
		p.write("DATA_RADIX=HEX;\n")
		p.write("\n")
		p.write("CONTENT BEGIN\n")

		curChar = 'F'
		word = ""
		address = 0x8000
		if (address > 0):
			p.write("\t[0.." + "{:02X}".format(address-1) + "] : 00;\n")

		while (curChar != '\n'):	# skip first line
			curChar = f.read(1)
		while True:
			while (curChar != ':' and curChar != ''):
				curChar = f.read(1)
			if (curChar == '' or address >= 0xFFFF):
				print("{:02X}".format(address))
				p.write("END;\n") 
				break
			curChar = f.read(1)
			for i in range(16):
				word = ""
				curChar = f.read(1)
				word = word + curChar
				curChar = f.read(1)
				word = word + curChar
				curChar = f.read(1)
				p.write("\t" + "{:02X}".format(address) + " : " + word + ";\n")
				address+=1
			while (curChar != '\n' and curChar != ''):
				curChar = f.read(1)

		c.write("WIDTH=8;\n")
		c.write("DEPTH=65536;\n")
		c.write("\n")
		c.write("ADDRESS_RADIX=HEX;\n")
		c.write("DATA_RADIX=HEX;\n")
		c.write("\n")
		c.write("CONTENT BEGIN\n")

		curChar = 'F'
		word = ""
		address = 0x0000
		while True:
			while (curChar != ':' and curChar != ''):
				curChar = f.read(1)
			if (curChar == '' or address >= 0x2000):
				print("{:02X}".format(address))
				c.write("END;\n") 
				break
			curChar = f.read(1)
			for i in range(16):
				word = ""
				curChar = f.read(1)
				word = word + curChar
				curChar = f.read(1)
				word = word + curChar
				curChar = f.read(1)
				c.write("\t" + "{:02X}".format(address) + " : " + word + ";\n")
				address+=1
			while (curChar != '\n' and curChar != ''):
				curChar = f.read(1)
if (__name__ == "__main__"):
	main()	
