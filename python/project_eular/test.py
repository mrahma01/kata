import unittest
from projecteular import *

class TestProjectEular(unittest.TestCase):
    def setUp(self):
        self.pe = ProjectEular()

    def test_problem_1(self):
        self.assertEqual(23, self.pe.problem_1(10))

    def test_problem_2(self):
        self.assertEqual(10, self.pe.problem_2(15))

if __name__ == "__main__":
    unittest.main()

