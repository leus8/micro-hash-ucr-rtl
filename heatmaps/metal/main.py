import sys
import csv
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm

def main (argv):

    debug = 0 # activates debug mode

    filename = sys.argv[1] # reads the filename from command argument

    # initializes coordinates list
    xp = []
    yp = []

    with open(filename) as file:
        # cvs file iterator
        for row in csv.reader(file):
            if (len(row) > 3):

                # Only add vertical connections
                if (row[3] != "*"): 
                    start = int(row[1])
                    end = int(row[3])
                    for diff in range(abs(end-start)):
                        if(end-start < 0):
                            yp.append(start - diff)
                        else:
                            yp.append(start + diff)
            
                        xp.append(row[0])

    xp = list(map(int,xp)) # casts list xp type string to type int
    yp = list(map(int,yp)) # casts list yp to type string to type int
    
    x = [a+320 for a in xp] # adds x-coordinate offset
    y = [b+300 for b in yp] # adds y-coordinate offset

    # casts list to ndarray
    x = np.array(x) 
    y = np.array(y)

    # for debugging
    if (debug):
        print(xp)
        print(yp)
        print(x)  
        print(y)

    # generates cell heatmap
    nbins = 400 # number of bins
    plt.hist2d(x,y,bins=[np.arange(0,99040,nbins),np.arange(0,94600,nbins)],cmap="viridis")
    plt.xlabel("x coordinate ( 1 unit = 100 microns)")
    plt.ylabel("y coordinate ( 1 unit = 100 microns)")
    plt.colorbar()
    plt.savefig('heatmaps/metal/metal_density.png')

if __name__ == '__main__':
    main(sys.argv[1])