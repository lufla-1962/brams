integer, parameter :: TS_INIT=1
integer, parameter :: TS_INPUT=2
integer, parameter :: TS_OUTPUT=3
integer, parameter :: TS_POST=4
integer, parameter :: TS_DYNAMICS=5
integer, parameter :: TS_PHYSICS=6
character(len=8), parameter :: names(6) = (/&
"INIT    ", &
"INPUT   ", &
"OUTPUT  ", &
"POST    ", &
"DYNAMICS", &
"PHYSICS " /)
