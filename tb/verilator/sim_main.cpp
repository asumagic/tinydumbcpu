#include "Vcpu.h"
#include "verilated.h"

#include <memory>

int main(int argc, char* argv[])
{
	Verilated::commandArgs(argc, argv);
	std::unique_ptr<Vcpu> top{new Vcpu()};

	unsigned long timer = 0;

	while (!Verilated::gotFinish())
	{
		top->eval();

		if (timer % 5 == 0)
		{
			top->clock = ~top->clock;
		}

		++timer;
	}
}