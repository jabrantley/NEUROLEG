/*----------------------------------------------------------
Description
Improved version of AS5045 library. 
Support offset and nbits resolution input 
-Example:
------------------------------------------------------------ 
Author: Trieu Phat Luu
Email: tpluu2207@gmail.com
Lab of Brain Machine Interface
University of Houston
Date: 
Version:
------------------------------------------------------------
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.*/

// --------------------------START---------------------------
#ifndef __SPI_ENCODER_H__
#define __SPI_ENCODER_H__
// Include related libraries
#include "Arduino.h" // Include header file
// Custom Struct type
typedef struct encStat_t{
	bool DECn;
	bool INCn;
	bool LIN;
	bool COF;
	bool OCF;
}encStat_t;

// Class Definition
class SPIencoder{
	private:
		uint8_t _csPin;			// Chip select pin
		uint8_t _clkPin;		// Clock pin
		uint8_t _dataPin;		// Data bit
		uint8_t _nbits;			// nbits resolution
		uint32_t readRegister(void);
	//
	public:
		uint8_t statbits;			// number of status bits
		SPIencoder(uint8_t csPin, uint8_t clkPin, uint8_t dataPin, uint8_t nbits); // Constructor
		uint32_t EncRaw(void);		// nbits Raw value
		float EncDeg(void);		// Conver to degree
		uint32_t EncStat(void);		// Status
		float EncCalib(int *range, float offset);
		void getEncStat(encStat_t &encStat);
}; 

#endif //
