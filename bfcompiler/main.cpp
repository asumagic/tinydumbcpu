// Compile Brainf*ck source downto TDCPU bitcode, usable by the simulator.

#include <cstddef>
#include <fstream>
#include <iostream>
#include <string>

void emit(const char* str)
{
	std::cout << str << '\n';
}

std::string read_file(const char* fname)
{
	std::fstream file{fname};
	return {std::istreambuf_iterator{file}, {}};
}

int main(int argc, char* argv[])
{
	if (argc != 2)
	{
		std::cerr << "Usage: ./bfc <source>\n";
		return 1;
	}

	std::string src = read_file(argv[1]);

	for (char c : src)
	{
		switch (c)
		{
		case '+': emit("000"); break;
		case '-': emit("001"); break;
		case '>': emit("010"); break;
		case '<': emit("011"); break;
		case '[': emit("100"); break;
		case ']': emit("101"); break;
		case '.': emit("110"); break;
		case ',': emit("111"); break;
		default: break;
		}
	}
}