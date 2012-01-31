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

cpdef list makeWeightsCorrect(list keyweights):
	cdef float maxweight = _calcMaxweight(keyweights)
	
	cdef list newfreqweights = list()
	
	cdef float weight
	
	for freq, weight in keyweights:
		try:
			newfreqweights.append((freq, weight / maxweight))
		except ZeroDivisionError:
			newfreqweights.append((freq, 1.0))
	
	return newfreqweights

cdef float _calcMaxweight(list keyweights):
	cdef float feedback = 0
	
	for key, weight in keyweights:
		if weight > feedback:
			feedback = weight
	
	return feedback