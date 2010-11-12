class ProjectEular(object):
    def problem_1(self, number):
        sum = 0
        for a in range(1, number):
            if (a%3==0 or a%5==0):
                sum += a
        return sum                
