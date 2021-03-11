pre.o : $(SRC_PATH)/pre.f90 utilsMod.o dump.o filesMod.o \
	chemMod.o memoryMod.o
	cp -f $< $(<F:.f90=.f90)
	$(F_COMMAND) $(<F:.f90=.f90)
	rm -f $(<F:.f90=.f90)

dump.o : $(DUMP_PATH)/dump.F90
	cp -f $< $(<F:.f90=.f90)
	$(F_COMMAND) $(<F:.f90=.f90)
	rm -f $(<F:.f90=.f90)

utilsMod.o : $(SRC_PATH)/utilsMod.f90 dump.o
	cp -f $< $(<F:.f90=.f90)
	$(F_COMMAND) $(<F:.f90=.f90)
	rm -f $(<F:.f90=.f90)

filesMod.o : $(SRC_PATH)/filesMod.f90 dump.o memoryMod.o chemMod.o\
	utilsMod.o
	cp -f $< $(<F:.f90=.f90)
	$(F_COMMAND) $(<F:.f90=.f90)
	rm -f $(<F:.f90=.f90)

memoryMod.o : $(SRC_PATH)/memoryMod.f90
	cp -f $< $(<F:.f90=.f90)
	$(F_COMMAND) $(<F:.f90=.f90)
	rm -f $(<F:.f90=.f90)

chem1_list.o : $(CHEM_MODEL_PATH)/chem1_list.f90
	cp -f $< $(<F:.f90=.f90)
	$(F_COMMAND) $(<F:.f90=.f90)
	rm -f $(<F:.f90=.f90)	

chemMod.o : $(SRC_PATH)/chemMod.f90 chem1_list.o memoryMod.o
	cp -f $< $(<F:.f90=.f90)
	$(F_COMMAND) $(<F:.f90=.f90)
	rm -f $(<F:.f90=.f90)

engineMod.o : $(SRC_PATH)/engineMod.f90 
	cp -f $< $(<F:.f90=.f90)
	$(F_COMMAND) $(<F:.f90=.f90)
	rm -f $(<F:.f90=.f90)