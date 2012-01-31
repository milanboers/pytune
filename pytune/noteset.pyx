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
import notefinder

def fromFreqSet(list freqSet):
	# Find note names
	cdef list noteSet
	
	noteSet = _findNoteNames(freqSet)
	# Sort for easier filtering
	noteSet = sorted(noteSet, key=lambda x: x[0])
	# Filter and group by note name, adding weights
	noteSet = _filterDuplicates(noteSet)
	
	return noteSet

cdef list _findNoteNames(freqSet):
	cdef list freqList = list(freqSet)
	cdef list fb = list()
	
	cdef float freq
	cdef float weight
	
	cdef str noteName
	
	for freq, weight in freqSet:
		noteName = notefinder.findNoteName(freq)
		fb.append((noteName, weight))
	
	return fb

cdef list _filterDuplicates(noteweights):
	cdef list newnoteset = list()
	
	cdef str prevNote = ''
	cdef float prevWeight = -1
	
	cdef float newWeight
	cdef str note
	cdef float weight
	
	for note, weight in noteweights:
		newWeight = weight
		
		if note == prevNote:
			newWeight = weight + prevWeight
			# Remove old one
			newnoteset.pop()
		
		newnoteset.append((note, newWeight))
		
		prevNote = note
		prevWeight = newWeight
	
	return newnoteset