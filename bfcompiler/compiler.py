import sys

if len(sys.argv) != 2:
	print("syntax: compiler.py bfsource.txt")
	exit(1)

source_map = {
	"+": 0,
	"-": 1,
	">": 2,
	"<": 3,
	"[": 4,
	"]": 5,
	".": 6,
	",": 7
}

hex_output = ""

with open(sys.argv[1]) as f:
	for c in f.read():
		if c in source_map:
			hex_output += "{:03b}\n".format(source_map[c])

print(hex_output)