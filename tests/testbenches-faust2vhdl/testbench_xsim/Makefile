all: sim

sim: input_samples.txt
	./test_bench_faust.sh
	pr -m -t input_samples.txt output_samples.txt 

#view: test_bench_faust.wdb
#	vivado test_bench_faust.wdb

view: project_sim.tcl
	vivado -mode batch -source project_sim.tcl -tclargs --origin_dir ${PWD}
	vivado project_sim/project_sim.xpr


test_bench_faust.wdb: sim


clean:
	\rm -rf xsim_* simulate_* *~ *.log xsim.* xvhdl.* file_info* webtalk* xelab* vivado* project_sim sim output_samples.txt


