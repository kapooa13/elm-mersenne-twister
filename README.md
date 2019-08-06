# Mersenne Generator

This project was made for the purpose of helping kids utilise PRNG in Elm, without using Commands required for the built in RNG in the core random module. The project follows the algorithm for Mersenne Twister, following the standard implementation of MT19937, which uses a 32-bit word length.

## Issues

* This is not cryptographically secure and should not be used for security purposes.
* It is to be noted that even though this is able to produce Pseudo Random Numbers, the bitwise operations did not produce the same results when done in Python. 

## Future work

This project was created with the intention of being utilised for the Outreach program in McMaster, now called McMaster Start Coding, and will hopefully be integrated into their program at some point. To learn more about them, see: outreach.mcmaster.ca.
