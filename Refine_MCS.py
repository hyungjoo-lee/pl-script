#!/usr/local/bin/python
# programmer : Bo
# usage:

import sys
import re
import random
import string
import time
import math

def main(X):
    try:
        print 'opening file :',X
        infile = open(X,"r+").readlines()
        print 'Total ',len(infile),' lines.'
        return infile
    except IOError,message:
        print >> sys.stderr, "cannot open file",message
        sys.exit(1)

if __name__=="__main__":
    tS = time.time()
    OP = main(sys.argv[1])
    for each in OP:
        OF = main(each[:-1])
        out = file(each[:-1]+'_MCS','w')
        out1 = file(each[:-1]+'_MCS.bed','w')
        for i in range(1,len(OF)):
            ea = OF[i]
            if 'unknown' in ea:
                continue
            te = ea[:-1].split(',')
            p = 0.01 * math.log10(float(te[9])+1e-99)

            if float(te[11]) > 0  :
                mcs = 1*p
            else:
                mcs = -1*p

            if abs(mcs) > 0.08 :
                out.write(ea[:-1]+','+str(mcs)+'\n')
                out1.write(te[0]+'\t'+te[1]+'\t'+te[2]+'\t'+str(mcs)+'\n')
        print 'finished',each
        out.close()
        out1.close()
    tE = time.time()
    print 'Cost ',(tE-tS),' sec'

