stack51
=======

Stack usage analysis for 8051 processors.

preprocessor.py
---------------

Reads lst file from stdin and outputs assembler code to stdout


main
----

Reads asm file from stdin or file and outputs stack usage for all interrupts.
Main function is under key ``__sdcc_program_startup``


TODO
----

* Count stack usage for library functions calls
* Take into accout operations on SP (now only warning)
* More verbose output
