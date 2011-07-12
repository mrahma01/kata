from lrange import lrange

class ProjectEular(object):
    def problem_1(self, number):
        """
        If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6 and 9. The sum 
        of these multiples is 23.

        Find the sum of all the multiples of 3 or 5 below 1000
        """    
        sum = 0
        for a in range(1, number):
            if (a%3==0 or a%5==0):
                sum += a
        return sum

    def problem_2(self, number):
        """
        Each new term in the Fibonacci sequence is generated by adding the previous two terms. By starting with 
        1 and 2, the first 10 terms will be:

        1, 2, 3, 5, 8, 13, 21, 34, 55, 89, ...

        Find the sum of all the even-valued terms in the sequence which do not exceed four million    
        """
        sum = 0
        a, b = 0, 1
        while a < number:
            if a % 2 == 0:
                sum += a
            a, b = b, a+b
        return sum

    def problem_3(self, num):
        """
        The prime factors of 13195 are 5, 7, 13 and 29.

        What is the largest prime factor of the number 600851475143
        """
        result = []
        for n in lrange(2, num):
            while(num%n==0):
                if(num%n==0):
                    num = num/n
                    result.append(n)
        return result