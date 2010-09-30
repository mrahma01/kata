import unittest
from backwardstalk import *

class TestBackwardsTalk(unittest.TestCase):

    def test_backwards_talk(self):
        self.assertEqual("sdrawkcab", reverse("backwards"))


if __name__ == '__main__':
    unittest.main()
