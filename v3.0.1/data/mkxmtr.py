import io
import string

print 'xmtr_id    freq     lat      lon    pwr incl headng alt'
for f in range(80, 301) :
  print 'NAA'     + ("%03d" % f) + ("%8.2f" % (f / 10.)) + '  44.645   67.283  1   0     0    0  Cutler, Maine'
for f in range(80, 301) :
  print 'NML'     + ("%03d" % f) + ("%8.2f" % (f / 10.)) + '  46.366   98.336  1   0     0    0  La Moure, North Dakota'
for f in range(80, 301) :
  print 'NLK'     + ("%03d" % f) + ("%8.2f" % (f / 10.)) + '  48.204  121.917  1   0     0    0  Jim Creek, Washington'
for f in range(80, 301) :
  print 'NAU'     + ("%03d" % f) + ("%8.2f" % (f / 10.)) + '  18.399   67.177  1   0     0    0  Aguada, Puerto Rico'
for f in range(80, 301) :
  print 'NPM'     + ("%03d" % f) + ("%8.2f" % (f / 10.)) + '  21.420  158.151  1   0     0    0  Lualualei, Hawaii'
for f in range(80, 301) :
  print 'GBZ'     + ("%03d" % f) + ("%8.2f" % (f / 10.)) + '  54.912    3.278  1   0     0    0  Anthorn, United Kingdom'
for f in range(80, 301) :
  print 'NWC'     + ("%03d" % f) + ("%8.2f" % (f / 10.)) + ' -21.816 -114.166  1   0     0    0  Harold E. Holt, Australia'
for f in range(80, 301) :
  print 'OMEGA_A' + ("%03d" % f) + ("%8.2f" % (f / 10.)) + '  66.420  -13.137  1   0     0    0  OMEGA A (Bratland, Norway)'
for f in range(80, 301) :
  print 'OMEGA_B' + ("%03d" % f) + ("%8.2f" % (f / 10.)) + '   6.305   10.664  1   0     0    0  OMEGA B (Paynesville, Liberia)'
for f in range(80, 301) :
  print 'OMEGA_C' + ("%03d" % f) + ("%8.2f" % (f / 10.)) + '  21.405  157.831  1   0     0    0  OMEGA C (Kaneohe, Hawaii)'
for f in range(80, 301) :
  print 'OMEGA_D' + ("%03d" % f) + ("%8.2f" % (f / 10.)) + '  46.366   98.336  1   0     0    0  OMEGA D (La Moure, North Dakota)'
for f in range(80, 301) :
  print 'OMEGA_E' + ("%03d" % f) + ("%8.2f" % (f / 10.)) + ' -20.974  -55.290  1   0     0    0  OMEGA E (La Reunion)'
for f in range(80, 301) :
  print 'OMEGA_F' + ("%03d" % f) + ("%8.2f" % (f / 10.)) + ' -43.054   65.191  1   0     0    0  OMEGA F (Golfo Nuevo, Argentina)'
for f in range(80, 301) :
  print 'OMEGA_G' + ("%03d" % f) + ("%8.2f" % (f / 10.)) + ' -38.481 -146.935  1   0     0    0  OMEGA G (Woodside, Australia)'
for f in range(80, 301) :
  print 'OMEGA_H' + ("%03d" % f) + ("%8.2f" % (f / 10.)) + '  34.615 -129.454  1   0     0    0  OMEGA H (Tsushima, Japan)'
print 'END'
