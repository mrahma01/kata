<?php
/*
The rules

Any number divisible by three is replaced by the word fizz and any divisible by five by the word buzz. Numbers divisible by both become fizzbuzz. A player who makes a mistake has to take a drink. 
Einstein will choose a random number to start with – for example: 4, buzz, fizz, 7, 8, fizz, buzz, 11, fizz, 13, 14, fizzbuzz
*/
class FizzBuzz {
    public $number;
    public $range;
    
    public function __construct(){
        $this->number   = 0;
        $this->range    = 0;
    }

    public function check_range($number, $range){
        $number = $number;
        $range = $range;
        $fizzbuzz = array();
        while($number < $range){
            $fizzbuzz[$number] = $this->check($number);
            $number ++;
        }
        return $fizzbuzz;
    }

    private function check($number){
        if($number % 3 == 0 && $number % 5 == 0)
            return "FizzBuzz";
       elseif ($number % 5 == 0)
            return "Buzz";
       elseif($number % 3 == 0)
            return "Fizz";
       else
            return $number;
    }
}
?>
