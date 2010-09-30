<?php

   interface fighter {
      function power();
      function weight();
   }

   class boxer implements fighter {

      private $power;
      private $weight;

      function power() {
         return $this->power;
      }

      function weight() {
         return $this->weight;
      }

}
?>

