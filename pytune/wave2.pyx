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

import numpy
import struct
import wave
import os

class Wave(object):
	"""
	Abstraction of a wave file
	"""
	def __init__(self, data, int sampleRate, *args, **kwargs):
		super(Wave, self).__init__(*args, **kwargs)
		
		self.data = data
		self.sampleRate = sampleRate

def getFromFile(str filename):
	"""
	Constructs a wave object from filename
	"""
	cdef int dataSize = (os.path.getsize(filename) - 44) / 2
	
	w = wave.open(filename, 'r')
	(nchannels, sampwidth, framerate, nframes, comptype, compname) = w.getparams()
	
	cdef str waveDataS = w.readframes(nframes)
	cdef tuple waveDataT = struct.unpack_from("%dh" % nframes, waveDataS)
	
	return Wave(waveDataT, framerate)