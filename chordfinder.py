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

import sys
import os
import threading
import Queue

from PyQt4 import QtCore, QtGui
from pytune import wave2, freqset, noteset, scalefinder, functions

class ResultTypes:
	CHORDS=1

class WavePlotterScene(QtGui.QGraphicsScene):
	clicked = QtCore.pyqtSignal(int)
	def __init__(self, *args, **kwargs):
		super(WavePlotterScene, self).__init__(*args, **kwargs)
		
	def mouseReleaseEvent(self, me):
		self.clicked.emit(me.scenePos().x())

class WavePlotter(QtGui.QGraphicsView):
	selected = QtCore.pyqtSignal(int, int)
	def __init__(self, *args, **kwargs):
		super(WavePlotter, self).__init__(*args, **kwargs)
		
		self._wave = None
		self._resolution = 3000
		
		self.markers = []
		
		self.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
	
	def resizeEvent(self, e):
		self.paint()
	
	def paint(self):
		if self._wave != None:
			self.scene = WavePlotterScene()
			self.scene.clicked.connect(self._sceneClicked)
			
			width = len(self._wave.data) / self._resolution
			height = self.height()
			self.setSceneRect(0, 0, width, height)
			
			pixmap = QtGui.QPixmap(width, height)
			pixmap.fill()
			painter = QtGui.QPainter(pixmap)
			
			maxs = self._wave.sampleRate / 2 * 1.1
			halfheight = self.height() / 2.0
			multiplier = (1.0 / maxs) * halfheight
			
			x = 0
			y = halfheight
			
			for i in xrange(0, len(self._wave.data), self._resolution):
				frag = self._wave.data[i] * multiplier + halfheight
				
				painter.drawLine(x, y, x + 1, frag)
				y = frag
				x += 1
			
			# Draw markers
			painter.setPen(QtGui.QColor(0, 0, 255))
			for marker in self.markers:
				painter.drawLine(marker / self._resolution, 0, marker / self._resolution, self.height())
			painter.setPen(QtGui.QColor(0, 0, 0))
			
			painter.end()
			
			self.scene.addPixmap(pixmap)
			self.setScene(self.scene)
	
	def _sceneClicked(self, x):
		if len(self.markers) > 1:
			self.markers = []
		self.markers.append(x * self._resolution)
		self.paint()
		if len(self.markers) > 1:
			if self.markers[0] > self.markers[1]:
				self.selected.emit(self.markers[1], self.markers[0])
			else:
				self.selected.emit(self.markers[0], self.markers[1])
	
	def zoomOut(self):
		self._resolution = int(self._resolution * 1.5)
		self.paint()
	
	def zoomIn(self):
		self._resolution = int(self._resolution / 1.5)
		self.paint()
	
	def setWave(self, wave):
		self._wave = wave
		self.markers = []
		self.paint()

class WavePlotterWidget(QtGui.QWidget):
	selected = QtCore.pyqtSignal(int, int)
	def __init__(self, *args, **kwargs):
		super(WavePlotterWidget, self).__init__(*args, **kwargs)
		
		layout = QtGui.QHBoxLayout()
		
		self.plotter = WavePlotter()
		self.plotter.selected.connect(self.selected.emit)
		
		layout.addWidget(self.plotter)
		
		buttonsLayout = QtGui.QVBoxLayout()
		
		zoomInButton = QtGui.QPushButton("+")
		zoomInButton.clicked.connect(lambda : self.plotter.zoomIn())
		buttonsLayout.addWidget(zoomInButton)
		zoomOutButton = QtGui.QPushButton("-")
		zoomOutButton.clicked.connect(lambda : self.plotter.zoomOut())
		buttonsLayout.addWidget(zoomOutButton)
		layout.addLayout(buttonsLayout)
		
		self.setLayout(layout)

class ChordOutputWidget(QtGui.QWidget):
	def __init__(self, chords, *args, **kwargs):
		super(ChordOutputWidget, self).__init__(*args, **kwargs)
		
		layout = QtGui.QHBoxLayout()
		
		firstLabel = QtGui.QLabel(chords[-1][0])
		firstLabel.setStyleSheet("font-size: 24px;")
		layout.addWidget(firstLabel)
		
		secondLabel = QtGui.QLabel(chords[-2][0])
		layout.addWidget(secondLabel)
		
		thirdLabel = QtGui.QLabel(chords[-3][0])
		layout.addWidget(thirdLabel)
		
		layout.addStretch()
		
		self.setLayout(layout)

class ResultsWidget(QtGui.QWidget):
	def __init__(self, *args, **kwargs):
		super(ResultsWidget, self).__init__(*args, **kwargs)
		
		self.currentWidget = None
		self.layout = QtGui.QHBoxLayout()
		self.setLayout(self.layout)
	
	def showResult(self, resultType, result):
		if self.currentWidget != None:
			self.layout.removeWidget(self.currentWidget)
			self.currentWidget.setParent(None)
		if resultType == ResultTypes.CHORDS:
			self.currentWidget = ChordOutputWidget(result)
			self.layout.addWidget(self.currentWidget)

class CentralWidget(QtGui.QWidget):
	# resulttype, result
	updateResult = QtCore.pyqtSignal(int, list)
	updateProgress = QtCore.pyqtSignal(int)
	updateProgressText = QtCore.pyqtSignal(str)
	def __init__(self, *args, **kwargs):
		super(CentralWidget, self).__init__(*args, **kwargs)
		
		self._setupUI()
		
		# Connect signals
		self.updateProgressText.connect(self.progressLabel.setText)
		self.updateProgress.connect(self.progressBar.setValue)
		self.updateResult.connect(self._updateResult)
	
	def _setupUI(self):
		layout = QtGui.QVBoxLayout()
		
		self.loadedLabel = QtGui.QLabel("Click the Open button to load a file.")
		layout.addWidget(self.loadedLabel)
		
		openButton = QtGui.QPushButton("Open...")
		openButton.clicked.connect(self._openWave)
		layout.addWidget(openButton)
		
		self.wavePlotterWidget = WavePlotterWidget()
		self.wavePlotterWidget.selected.connect(self._selected)
		layout.addWidget(self.wavePlotterWidget)
		
		self.outputWidget = ResultsWidget()
		layout.addWidget(self.outputWidget)
		
		self.progressLabel = QtGui.QLabel()
		layout.addWidget(self.progressLabel)
		
		self.progressBar = QtGui.QProgressBar()
		self.progressBar.setMinimum(0)
		self.progressBar.setMaximum(100)
		layout.addWidget(self.progressBar)
		
		self.setLayout(layout)
	
	def _updateResult(self, resultType, result):
		self.outputWidget.showResult(resultType, result)
	
	def _openWave(self):
		filename = str(QtGui.QFileDialog.getOpenFileName(self, "Open wave file..."))
		if filename != "":
			self.wave = wave2.getFromFile(filename)
			self.loadedLabel.setText(os.path.basename(filename))
			self.wavePlotterWidget.plotter.setWave(self.wave)
	
	def _calcChordThread(self, begin, end):
		self.updateProgressText.emit("Opening wave...")
		wave = wave2.Wave(self.wave.data[begin:end], self.wave.sampleRate)
		
		self.updateProgressText.emit("Analyzing frequencies...")
		freqs = freqset.fromWave(wave)
		self.updateProgress.emit(40)
		
		self.updateProgressText.emit("Grouping into notes...")
		notes = noteset.fromFreqSet(freqs)
		self.updateProgress.emit(80)
		
		self.updateProgressText.emit("Finding chords...")
		chords = scalefinder.findTriad(notes)
		self.updateProgress.emit(85)
		
		self.updateProgressText.emit("Correcting weights...")
		chords = functions.makeWeightsCorrect(chords)
		self.updateProgress.emit(90)
		
		self.updateProgressText.emit("Sorting to likeliness...")
		chords = sorted(chords, key=lambda x: x[1])
		
		self.updateProgress.emit(0)
		self.updateProgressText.emit("")
		
		self.updateResult.emit(ResultTypes.CHORDS, chords)
	
	def _selected(self, begin, end):
		t = threading.Thread(target=self._calcChordThread, args=(begin, end,))
		t.start()

class MainWindow(QtGui.QMainWindow):
	def __init__(self, *args, **kwargs):
		super(MainWindow, self).__init__(*args, **kwargs)
		
		self.setCentralWidget(CentralWidget())
		
		self.show()

if __name__ == '__main__':
	app = QtGui.QApplication(sys.argv)
	ex = MainWindow()
	sys.exit(app.exec_())