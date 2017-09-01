#!/usr/bin/env python
#
# Project Librarian: Dipongkar Talukder
#                    Postdoctoral Scholar
#                    University of Oregon / LIGO Scientific Collaboration
#                    <dipongkar.talukder@ligo.org>
#
# Copyright (C) 2013 Dipongkar Talukder
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

from distutils.core import setup

setup(
	name='gwgrbprocessor',
	version='0.0',
	url='https://wiki.ligo.org/viewauth/Bursts/GRBGroup',
	author='Dipongkar Talukder, et. al.',
	author_email='dipongkar.talukder@ligo.org',
	description='GRB Gravitational-wave Online Processor',
	license='GNU General Public License Version 3',
	packages=['gwgrbprocessor'],
	scripts=[
		'bin/queryGraceDB',
		'bin/XprocessGRB',
		'bin/XmonitorGRB',
		'bin/XmonitorPostproc',
		'bin/XmonitorOpenbox',
		'bin/CBCprocessGRB',
		'bin/CBCmonitorGRB',
		'bin/CBCmonitorPostproc',
		'bin/CBCmonitorOpenbox',
		'bin/monitorJobs',	
		'bin/DetStatusCircularGenerator',
		'bin/ResultsCircularGenerator'
	]
)
