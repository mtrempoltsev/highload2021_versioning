RUN_DIR = $(shell pwd)/run

all: test

scd_type_1: data
	tarantool ./runner.lua scd_type_1 ${RUN_DIR}

scd_type_2: data
	tarantool ./runner.lua scd_type_2 ${RUN_DIR}

scd_type_4: data
	tarantool ./runner.lua scd_type_4 ${RUN_DIR}

bench: scd_type_1 scd_type_2 scd_type_4

test: data
	tarantool ./run_tests.lua ${RUN_DIR}

data: make_run_dir
	if [ ! -f ${RUN_DIR}/profiles.jsonl ] || [ ! -f ${RUN_DIR}/changes.jsonl ] ; then \
		python3 ./make_data.py -o ${RUN_DIR}; \
	fi

make_run_dir:
	mkdir -p $(RUN_DIR)

clean:
	rm -r ${RUN_DIR}
