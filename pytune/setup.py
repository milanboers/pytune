#! /usr/bin/env python
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

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules = [
Extension("functions", ["functions.pyx"]),
Extension("notefinder", ["notefinder.pyx"]),
Extension("wave2", ["wave2.pyx"]),
Extension("freqset", ["freqset.pyx"]),
Extension("noteset", ["noteset.pyx"]),
Extension("scalefinder", ["scalefinder.pyx"])
]

setup(
  name = 'pytune',
  cmdclass = {'build_ext': build_ext},
  ext_modules = ext_modules
)