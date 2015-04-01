#!/usr/bin/env python

# Copyright (C) 2011 Duncan Macleod
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3 of the License, or (at your
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# =============================================================================
# Preamble
# =============================================================================

from __future__ import division
from optparse import OptionParser
import sys
from math import sqrt

# =============================================================================
# Parse command line
# =============================================================================

def parse_command_line():
  usage = """usage: %prog [options]

This script will calculate the 68% containment radius for a given GRB using quoted error radius and knowledge of the uncertainties for each satellite.
"""

  parser = OptionParser(usage=usage)

  parser.add_option("-s", "--satellite", action="store", type="string",\
                     default=None, help="name of GRB satellite")

  parser.add_option("-e", "--error", action="store", type="float",\
                     default=None, help="quoted error radius (arcmin)")

  parser.add_option("-n", "--num-sigma-error", action="store", type="float",\
                     default=1, help="number of sigma error required")

  parser.add_option("-a", "--systematic-error", action="store", type="float",\
                     default=None, help="systematic error, satellite specific")

  (opts, args) = parser.parse_args()

  if not opts.satellite:
    parser.error("Must provide --satellite")

  if not opts.error:
    parser.error("Must provide --error")

  return opts,args

def main(satellite, error, sigma=1, syst=None):

  # convert types
  satellite = satellite.lower()
  error = float(error)
  errdeg = error/60

  # set systematic
  systematic = {'swift':0.0, 'swiftsub':0.0, 'swift/ipn':0.0, 'integral':0.0,\
                'fermi':3.8, 'superagile':0.0, 'fermilat':0.1}
  if not syst:
    syst = systematic[satellite]

  # swift/integral quote 90% containment
  if satellite in ['swift', 'swiftsub', 'swift/ipn', 'integral']:
    stat = errordeg / 1.4
  
  # fermi has 3.8deg systematic
  elif satellite in ['fermi']:
    stat = errdeg

  # assumed SuperAGILE quotes 68%
  elif satellite in ['superagile']:
    stat = errdeg

  # FermiLAT quotes 90% ith 0.1deg systematic
  elif satellite in ['fermilat']:
    stat = errdeg / 1.4

  else:
    AttributeError, 'Cannot parse satellite = %s' % satellite

  # calculate containment
  containment = sqrt(stat**2 + syst**2)

  # convert to degrees
  containment *= numsigma
  containmentdeg = containment / 60
  #print numsigma
  #print containmentdeg
  print "%.3f" % containment

if __name__=='__main__':

  opts, args = parse_command_line()
  satellite  = opts.satellite
  error      = opts.error
  numsigma   = opts.num_sigma_error
  systematic = opts.systematic_error

  main(satellite, error, sigma=numsigma, syst=systematic)
