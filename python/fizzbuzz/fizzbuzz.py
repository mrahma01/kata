"""
The rules

Any number divisible by three is replaced by the word fizz and any divisible by five by the word buzz. Numbers divisible by both become fizzbuzz. A player who makes a mistake has to take a drink. 
Einstein will choose a random number to start with,for example: 4, buzz, fizz, 7, 8, fizz, buzz, 11, fizz, 13, 14, fizzbuzz
"""

from operator import mod, eq

def check_range(x=9,r=99):
    return [check(value) for value in range(x,r)]
    

def check(x=9):
    a = eq(0,mod(x,3))
    b = eq(0,mod(x,5))

    if a & b:
        return "Fizz Buzz"
    elif a:
        return "Fizz"
    elif b:
        return "Buzz"
    else:
        return x

