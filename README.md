![Picture](https://github.com/nrj/LEDMatrixControl/raw/master/picture.png)

## Hardware

*	Arduino Duemilanove *(any ATMega based board should work)*
*	8x8 RGB LED Matrix *(I am using [this](http://cgi.ebay.com.sg/8-8-60-60mm-RGB-Full-Color-Dot-Matrix-LED-Display-/190502734111?pt=LH_DefaultDomain_0&hash=item2c5ad9091f#ht_4697wt_689) one)*
*	4 x [74HC595](http://www.sparkfun.com/products/733) Shift Registers
*	8 x 330 Ohm Resistors
*	16 x 220 Ohm Resistors

## Schematic

![Schematic](https://github.com/nrj/LEDMatrixControl/raw/master/schematic.png)

By [Francis Shanahan](http://picasaweb.google.com/lh/photo/4m0f5w6KA1bAIHIswXBFcg?feat=embedwebsite)

## Optional PCB

Designed by me. Can be ordered here: http://batchpcb.com/index.php/Products/47075

**Important**: A couple of the labels on this PCB are incorrect. The Red + Blue IC's are switched, and the Clock (C) and Latch (L) pins on the bottom left are switched.