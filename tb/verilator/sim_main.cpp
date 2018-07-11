#include "Vcpu.h"
#include "verilated.h"

#include <iostream>
#include <memory>

int main(int argc, char* argv[])
{
	Verilated::commandArgs(argc, argv);
	std::unique_ptr<Vcpu> top{new Vcpu()};

	unsigned long timer = 0;
	bool was_high_clock = false;

	while (!Verilated::gotFinish())
	{
		top->eval();

		// Rising edge
		if (top->clock && !was_high_clock)
		{
			if (top->out_en)
			{
				std::cout << char(top->out_data) << std::flush;
			}

			was_high_clock = true;
		}

		if (!top->clock)
		{
			was_high_clock = false;
		}

		if (timer % 2 == 0)
		{
			top->clock = ~top->clock;
		}

		++timer;
	}
}