# Mersenne Generator

This project was made for the purpose of helping kids utilise PRNG in Elm, without using Commands required for the built in RNG in the core random module. The project follows the algorithm for Mersenne Twister, following the standard implementation of MT19937, which uses a 32-bit word length.

## Issues

* This is not cryptographically secure and should not be used for security purposes.
* It is to be noted that even though this is able to produce Pseudo Random Numbers, the bitwise operations did not produce the same results when done in Python. 

## Future work

This project was created with the intention of being utilised for the Outreach program in McMaster, now called McMaster Start Coding, and will hopefully be integrated into their program at some point. From their website:

>At Software: Tool For Change, we provide elementary and middle school students with a fun and safe environment to learn code. We incorporate mathematical concepts such as the cartesian coordinate system and trigonometry. We have seen students understand things that they have learned in class better by playing with the tools we have provided.

To learn more about them, see: http://outreach.mcmaster.ca.
