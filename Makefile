.PHONY: test clean

test.hex: test.S
	@avr-gcc -nostartfiles -mmcu=atmega16 -o test test.S
	@avr-objcopy -O ihex test test.hex

test: test.hex
	@avrdude -p m16 -c usbasp -U test.hex

clean:
	@rm test.hex test
