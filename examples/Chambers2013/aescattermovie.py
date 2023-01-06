#!/usr/bin/env python3
import swiftest 
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import animation
import matplotlib.colors as mcolors

titletext = "Chambers (2013)"
radscale = 2000
xmin = 0.0
xmax = 2.20
ymin = 0.0 
ymax = 1.0
framejump = 1

class AnimatedScatter():
    """An animated scatter plot using matplotlib.animations.FuncAnimation."""
    def __init__(self, ds, param):

        frame = 0
        nframes = int(ds['time'].size / framejump)
        self.ds = ds
        self.param = param
        self.Rcb = self.ds['radius'].sel(name="Sun").isel(time=0).values[()]

        self.clist = {'Initial conditions' : 'xkcd:faded blue',
                      'Disruption' : 'xkcd:marigold',
                      'Supercatastrophic' : 'xkcd:shocking pink',
                      'Hit and run fragmentation' : 'xkcd:baby poop green'}

        # Setup the figure and axes...
        fig = plt.figure(figsize=(8,4.5), dpi=300)
        plt.tight_layout(pad=0)
        # set up the figure
        self.ax = plt.Axes(fig, [0.1, 0.15, 0.8, 0.75])
        self.ax.set_xlim(xmin, xmax)
        self.ax.set_ylim(ymin, ymax)
        fig.add_axes(self.ax)
        self.ani = animation.FuncAnimation(fig, self.update, interval=1, frames=nframes, init_func=self.setup_plot, blit=True)
        self.ani.save('aescatter.mp4', fps=60, dpi=300, extra_args=['-vcodec', 'libx264'])
        print('Finished writing aescattter.mp4')

    def scatters(self, pl, radmarker, origin):
        scat = []
        for key, value in self.clist.items():
            idx = origin == key
            s = self.ax.scatter(pl[idx, 0], pl[idx, 1], marker='o', s=radmarker[idx], c=value, alpha=0.75, label=key)
            scat.append(s)
        return scat

    def setup_plot(self):
        # First frame
        """Initial drawing of the scatter plot."""
        t, name, Gmass, radius, npl, pl, radmarker, origin = next(self.data_stream(0))

        # set up the figure
        self.ax.margins(x=10, y=1)
        self.ax.set_xlabel("Semimajor Axis (AU)", fontsize='16', labelpad=1)
        self.ax.set_ylabel("Eccentricity", fontsize='16', labelpad=1)

        self.title = self.ax.text(0.50, 1.05, "", bbox={'facecolor': 'w', 'alpha': 0.5, 'pad': 5}, transform=self.ax.transAxes,
                        ha="center")

        self.title.set_text(f"{titletext} -  Time = ${t*1e-6:6.2f}$ My with ${npl:4.0f}$ particles")
        slist = self.scatters(pl, radmarker, origin)
        self.s0 = slist[0]
        self.s1 = slist[1]
        self.s2 = slist[2]
        self.s3 = slist[3]
        leg = plt.legend(loc="upper right", scatterpoints=1, fontsize=10)
        for i,l in enumerate(leg.legendHandles):
           leg.legendHandles[i]._sizes = [20]
        return self.s0, self.s1, self.s2, self.s3, self.title

    def data_stream(self, frame=0):
        while True:
            d = self.ds.isel(time = frame)
            name_good = d.name.where(d['status'] != 1, drop=True)
            name_good = name_good.where(name_good != "Sun", drop=True)
            d = d.sel(name=name_good) 
            d['radmarker'] = (d['radius'] / self.Rcb) * radscale
            radius = d['radmarker'].values

            radius = d['radmarker'].values
            Gmass = d['Gmass'].values
            a = d['a'].values 
            e = d['e'].values
            name = d['name'].values
            npl = d['npl'].values
            radmarker = d['radmarker']
            origin = d['origin_type']

            t = self.ds.coords['time'].values[frame]

            yield t, name, Gmass, radius, npl, np.c_[a, e], radmarker, origin

    def update(self,frame):
        """Update the scatter plot."""
        t, name, Gmass, radius, npl, pl, radmarker, origin = next(self.data_stream(framejump * frame))

        self.title.set_text(f"{titletext} - Time = ${t*1e-6:6.3f}$ My with ${npl:4.0f}$ particles")

        # We need to return the updated artist for FuncAnimation to draw..
        # Note that it expects a sequence of artists, thus the trailing comma.
        s = [self.s0, self.s1, self.s2, self.s3]
        for i, (key, value) in enumerate(self.clist.items()):
            idx = origin == key
            s[i].set_sizes(radmarker[idx])
            s[i].set_offsets(pl[idx,:])
            s[i].set_facecolor(value)

        self.s0 = s[0]
        self.s1 = s[1]
        self.s2 = s[2]
        self.s3 = s[3]
        return self.s0, self.s1, self.s2, self.s3, self.title,

sim = swiftest.Simulation(read_old_output=True)
print('Making animation')
anim = AnimatedScatter(sim.data,sim.param)
print('Animation finished')
