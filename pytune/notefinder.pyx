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

from libc.math cimport log2, round, fmod
from libc.stdlib cimport ldiv

cdef list _noteNames = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]

cpdef str findNoteName(float freq):
	"""
	Find a note name from a frequency
	"""
	cdef int halfsteps = <int>fmod(round(log2(freq / 440) * 12), 12)
	return _noteNames[halfsteps]

"""
cpdef tuple findNote(float freq):
	"#""
	Finds a note from a frequency
	"#""
	cdef float halfstepsF = log2(freq / 440) * 12
	
	cdef int octaves
	cdef int halfsteps
	(octaves, halfsteps) = divmod(int(round(halfstepsF)), 12)
	return (_noteNames[halfsteps], 4 + octaves)
"""