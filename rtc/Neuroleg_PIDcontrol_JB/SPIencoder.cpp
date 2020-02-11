/*----------------------------------------------------------
Description
-Input:
-Output: 
-Example:
------------------------------------------------------------ 
Author: Trieu Phat Luu
Email: tpluu2207@gmail.com
Lab of Brain Machine Interface
University of Houston
Date: 
Version:
----------------------------------------------------------
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.*/

// --------------------------START---------------------------
// Include related libraries
#include "SPIencoder.h" // Include header file

SPIencoder::SPIencoder(uint8_t csPin, uint8_t clkPin, uint8_t dataPin, uint8_t nbits){
	_csPin = csPin;
	_clkPin = clkPin;
	_dataPin = dataPin;
	pinMode(_csPin, OUTPUT);
	pinMode(_clkPin, OUTPUT);
	pinMode(_dataPin, INPUT);
	_nbits = nbits;
	statbits = 6; // number of status bit, 6 for AS5045
}

uint32_t SPIencoder::readRegister(void){
	// Initiate variables
	uint8_t inputstream = 0;
	int outputVal = 0;
	uint8_t nbitsRead = _nbits + statbits; 
	// Pull down csPin and clkPin to start spi
	digitalWrite(_csPin, HIGH);
	digitalWrite(_clkPin, HIGH);
	delay(1);
	digitalWrite(_csPin, LOW);
	digitalWrite(_clkPin, LOW);
	for (int i = 0; i < nbitsRead; i++){
		digitalWrite(_clkPin, HIGH);
		delayMicroseconds(3);
		inputstream = digitalRead(_dataPin);
		outputVal = (outputVal << 1) + inputstream;
		digitalWrite(_clkPin, LOW);
	}
	return outputVal;
}

uint32_t SPIencoder::EncRaw(void){
	// Get nbits raw encoder value
	// Read register and remove status bits
	return ((readRegister()) >> statbits);
}

float SPIencoder::EncDeg(void){
	// Return encoder value in degrees
	return (EncRaw()*360)/(1 << _nbits);
}

float SPIencoder::EncCalib(int *range, float offset){
	// Calibrate and return encoder value.
	float degCalib = EncDeg();		// 0-360 degs
	// Offset
	degCalib += offset;
	if (degCalib > 360) degCalib -= 360;
	if (degCalib < 0) degCalib += 360;
	// Calibrate to input range.
	degCalib = (range[1]-range[0])*degCalib/360 + range[0];
	return degCalib;
}

void SPIencoder::getEncStat(encStat_t &encStat){
	uint16_t status_code;
	uint32_t raw_value;
	raw_value = readRegister();
	status_code = raw_value & 0b000000000000111111;
	encStat.DECn = status_code & 2;		// high if magnet move away from IC
	encStat.INCn = status_code  & 4;		// high if magnet move toward IC		 
	encStat.LIN = status_code  & 8;		// high: linearity warning
	encStat.COF = status_code  & 16;		// high: data invalid
	encStat.OCF = status_code  & 32;		// high: chip startup is finished
}
