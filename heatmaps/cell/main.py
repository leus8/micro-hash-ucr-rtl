import sys
import csv
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.colors import LogNorm

def main (argv):

    filename = sys.argv[1]

    print(filename)

    x = []
    y = []
    data = []

    with open(filename) as file:

        for row in csv.reader(file):
            x.append(row[0])
            y.append(row[1])
            data.append(row)

    #x = [a+320 for a in x]
    #y = [a+300 for a in y]
    x = np.array(x)
    y = np.array(y)
    data = np.array(data)
    print(x)
    print(y)
    plt.hist2d(x,y,bins=[np.arange(0,47360,500),np.arange(0,33300,500)],norm=LogNorm())
    #ax = sns.heatmap(data)
    plt.colorbar()
    plt.show()

if __name__ == '__main__':
    main(sys.argv[1])