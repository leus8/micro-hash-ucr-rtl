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

    # DEF CONFIG

    # Die length offset
    xoffset = 320
    yoffset = 300

    # Number of tracks for metal 4
    num_tracks = 614

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

    # Add offsets to each entry
    x = [a+xoffset for a in xp]
    y = [b+yoffset for b in yp]

    # casts list to ndarray
    x = np.array(x) 
    y = np.array(y)

    # for debugging
    if (debug):
        print(xp)
        print(yp)
        print(x)  
        print(y)

    # Generate heatmap and save image
    nbins = 20 # number of bins
    h = plt.hist2d(x,y,bins=nbins,cmap="viridis")
    plt.xlabel("x coordinate ( 1 unit = 100 microns)")
    plt.ylabel("y coordinate ( 1 unit = 100 microns)")
    plt.colorbar()
    plt.savefig('heatmaps/metal/metal_density.png')

    # Histogram post processing
    
    # Histogram values for each bin
    # rotated by 90 degrees to match generated image
    bin_values = np.rot90(h[0])

    # Distance between Y axis bins
    yedges = h[2]

    # Average track per bin
    avg_track_num = num_tracks/nbins

    print("Average tracks per bin:", avg_track_num)

    # Maximum track usage
    max_track_usage = (yedges[1] - yedges[0])*avg_track_num

    # Track usage for every bin
    track_usage = [[int((bin/max_track_usage)*100) for bin in bins] for bins in bin_values]

    # Print track usage
    print("Track usage per bin (%):")
    print('\n'.join([''.join(['{:4}'.format(item) for item in row]) 
      for row in track_usage]))

if __name__ == '__main__':
    main(sys.argv[1])