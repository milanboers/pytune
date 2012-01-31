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

cdef tuple _noteNames = ("A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#")

cpdef list findScale(notes):
	cdef list fb = list()
	
	cdef int noteIndex
	cdef tuple majorScale
	cdef tuple naturalMinorScale
	
	cdef float majorScaleProb
	cdef float natMinScaleProb
	
	cdef str notename
	cdef float weight
	
	for noteIndex in xrange(len(_noteNames)):
		majorScale = _majorScale(noteIndex)
		naturalMinorScale = _naturalMinorScale(noteIndex)
		
		majorScaleProb = 0.0
		natMinScaleProb = 0.0
		
		for notename, weight in notes:
			if notename in majorScale:
				majorScaleProb += weight
			if notename in naturalMinorScale:
				natMinScaleProb += weight
		
		fb.append((_noteNames[noteIndex], majorScaleProb))
		fb.append((_noteNames[noteIndex] + 'm', natMinScaleProb))
	
	return fb

cpdef list findTriad(notes):
	cdef list fb = list()
	
	cdef int noteIndex
	cdef tuple majorTriad
	cdef tuple naturalMinorTriad
	
	cdef float majorTriadProb
	cdef float natMinTriadProb
	
	cdef str notename
	cdef float weight 
	
	for noteIndex in xrange(len(_noteNames)):
		majorTriad = _triad(_majorScale(noteIndex))
		naturalMinorTriad = _triad(_naturalMinorScale(noteIndex))
		
		majorTriadProb = 0.0
		natMinTriadProb = 0.0
		
		for notename, weight in notes:
			if notename in majorTriad:
				majorTriadProb += weight
			if notename in naturalMinorTriad:
				natMinTriadProb += weight
		
		fb.append((_noteNames[noteIndex], majorTriadProb))
		fb.append((_noteNames[noteIndex] + 'm', natMinTriadProb))
	
	return fb

cdef tuple _triad(scale):
	return (scale[0], scale[2], scale[4])

cdef tuple _majorScale(start):
	# Whole Whole Half Whole Whole Whole
	return (_noteNames[start % 12],
			_noteNames[(start + 2) % 12],
			_noteNames[(start + 4) % 12],
			_noteNames[(start + 5) % 12],
			_noteNames[(start + 7) % 12],
			_noteNames[(start + 9) % 12],
			_noteNames[(start + 11) % 12])

cdef tuple _naturalMinorScale(start):
	# Whole Half Whole Whole Half Whole
	return (_noteNames[start % 12],
			_noteNames[(start + 2) % 12],
			_noteNames[(start + 3) % 12],
			_noteNames[(start + 5) % 12],
			_noteNames[(start + 7) % 12],
			_noteNames[(start + 8) % 12],
			_noteNames[(start + 10) % 12])