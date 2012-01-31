# -*- coding: utf-8 -*-

#	Copyright 2011-2012, Milan Boers
#
#	This file is part of PyTune.
#
#	PyTune is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	PyTune is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with PyTune.  If not, see <http://www.gnu.org/licenses/>.

import functions
import numpy

def fromWave(wave):
	weight = numpy.abs(numpy.fft.fft(wave.data))
	freqs = numpy.abs(numpy.fft.fftfreq(len(wave.data)))
	
	# Compute array of frequency values from this
	cdef list freqsl = _valsToFreqs(freqs, wave.sampleRate)
	
	cdef list freqweights
	
	# Combine these two
	freqweights = zip(freqsl, weight)
	
	# Sort this to quickly filter out duplicates
	freqweights = sorted(freqweights, key=lambda x: x[0])
	
	# Remove the frequency 0 (because that's silence)
	freqweights.pop(0)
	
	# Filter out duplicates, but add weights of duplicates
	freqweights = _filterDuplicateFreqs(freqweights)
	
	return freqweights

cdef list _valsToFreqs(freqs, float sampleRate):
	cdef list fb = []
	cdef float f
	
	for f in freqs:
		fb.append(f * sampleRate)
	return fb

cdef list _filterDuplicateFreqs(freqweights):
	cdef list newfreqweights = list()
	
	cdef float newWeight
	cdef float newFreq
	
	cdef float freq
	cdef float weight
	
	# Set to values they can never be. To replace "None"
	cdef float prevFreq = -1
	cdef float prevWeight = -1
	
	for freq, weight in freqweights:
		newWeight = weight
		
		if freq == prevFreq:
			newWeight = weight + prevWeight
			# Remove the old one
			newfreqweights.pop()
		
		# Add the new one
		newfreqweights.append((freq, newWeight))
		
		prevFreq = freq
		prevWeight = weight
	
	return newfreqweights