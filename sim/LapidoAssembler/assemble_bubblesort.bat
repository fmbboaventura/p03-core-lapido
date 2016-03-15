call run_assembler ../bubblesort.asm -p inst_in.txt -d data_in.txt
copy /Y assembled_files\inst_in.txt ..\..\rtl\data\inst_in.txt
copy /Y assembled_files\data_in.txt ..\..\rtl\data\data_in.txt
