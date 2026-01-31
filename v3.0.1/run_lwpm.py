import io
import string
import subprocess
import sys
import os
import random

def remove_f(fname) :
	try :
		os.remove(fname)
	except OSError :
		pass

def write_inp_file(h, b, f, txname, rxlat, rxlon, basename) :
  ifile = open(basename + ".inp", "w")
  lines = [ "case-id     run_wlpm() Python",
    "tx          " + basename,
    "tx-data     " + txname + ("%03d" % int(round(10 * f))),
    "ionosphere  homogeneous exponential " + ("%8.6f" % b) + " " +  ("%8.6f" % h),
    "range-max   10000.0",
    "receivers   " + ("%8.3f" % rxlat) + " " + ("%8.3f" % rxlon),
    "mc-options  full-wave 0 true",
    "lwflds",
    "print-mds   1",
    "print-wf    1",
    "print-lwf   1",
    "start",
    "quit" ]
  ifile.write("\n".join(lines))
  ifile.close()
  
def rearrange_data(data) :
  values = []
  for line in data :
    values.append(line[0:28])
  for line in data :
    values.append("  " + line[29:54])
  for line in data :
    values.append(" " + line[55:81])
  # remove blank lines 
  values = [ line for line in values if len(line.strip()) > 0 ]
  #remove the RX location
  values.pop()
  return values
  
def proc_log_file(basename) :
	try :
		logfilename = '.'.join([basename, 'log'])
		#print logfilename
		with open(logfilename) as lfile :
			lines = lfile.readlines()
	except IOError :
		return ["exception!"]
	if len(lines) < 40 :
		return ["too short!"]
	slines = []
	for l in lines :
		slines.append(l.strip())
	istart = slines.index("dist   amplitude  phase    dist   amplitude  phase    dist   amplitude  phase") + 1
	iend = slines.index("nc nrpt bearng  rhomx  rlat   rlon   rrho    pwr    dist incl headng talt ralt     date/time")
	return rearrange_data(lines[istart:iend])

basename = "lwpm-python-" + str(os.getpid()) + "-" + ''.join(random.SystemRandom().choice(string.ascii_uppercase + string.digits) for _ in range(6))
if len(sys.argv) >= 7 :
	f = float(sys.argv[1])
	h = float(sys.argv[2])
	b = float(sys.argv[3])
	txname = sys.argv[4]
	rxlat = float(sys.argv[5])
	rxlon = float(sys.argv[6])
	remove_f(basename + ".inp")
	write_inp_file(h, b, f, txname, rxlat, rxlon, basename)
	remove_f(basename + ".lwf")
	remove_f(basename + ".mds")
	remove_f(basename + ".log")
	try :
		subprocess.check_call(["./lwpm", basename])
	except subprocess.CalledProcessError :
		remove_f(basename + ".log")
	remove_f(basename + ".inp")
	remove_f(basename + ".lwf")
	remove_f(basename + ".mds")
	data = proc_log_file(basename)
	#remove_f(basename + ".log")
	#print "\n".join(data)
else :
	print "Usage: python " + sys.argv[0] + " f_khz h_km b_km_inv txname rx_lat_deg rx_lon_deg"
      

