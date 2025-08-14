#!/usr/bin/env python
# coding: utf-8

# # Notebook with examples for Land-Climate Dynamics Practical Session 4: Analysing CLM

# First, let's load the following python packages: 
# 
# - [xarray](http://xarray.pydata.org/en/stable/): package to load and manipulate netcdf data
# - [cartopy](https://scitools.org.uk/cartopy/docs/latest/): package to produce geospatial maps (we will use it for the coordinate reference system)
# - [matplotlib](https://matplotlib.org/): the well-know plotting package
# - numpy
# 
# If you did not yet install these packages, use conda or pip in your terminal to install them (e.g. ```conda install xarray```)
# 

import xarray as xr
import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import numpy as np


# ## 1. Open the dataset
# We use xarray to open the netcdf file into a **dataset** object (ds). This object contains the variables, dimensions and coordinates

filename = 'control_merged.nc'

ds = xr.open_dataset(filename, decode_times=False)

# look what's inside the dataset (click data variables)
ds


# Next, we open one variable, specified by its name into a **data-array** (da) object. This object include some basic information on the variable itself. Here we showcase the runoff variable
# 

# load the runoff variable and check its attributes
da = ds['QRUNOFF']

#print the data array
da

# get the longitude variable from the data array
da['lon']

# check the units of the longitude
da['lon'].units

# check the units of the variable itself
da.units


# access the values of the variable as a numpy array
da.values


# ## 2. Manipulate data using xarray
# We can use xarray to manipulate data directly in python, like calculating means, standard deviations, take time slices etc ... You can find all functionality in the xarray online [documentation](http://xarray.pydata.org/en/stable/getting-started-guide/quick-overview.html). 

# calculate mean over the time dimension
da_mean = da.mean('time')

# look at the result
da_mean


# ## 3. Plotting the data
# Next we will use xarray to plot the data.

# define plotting parameters
# variable 
da_toplot = da_mean

# title 
title = 'example plot'

# define colormap (more info on colormaps: https://matplotlib.org/users/colormaps.html)
cmap = 'GnBu'

# define colorbar label (including unit!)
cbar_label = 'colorbar label (units)'

# define the projection
projection = ccrs.PlateCarree()


# define figure, projection and axes object
fig = plt.figure(figsize=(15,6))
proj=ccrs.PlateCarree()
ax = plt.subplot(111, projection=proj, frameon=False)

# do plotting based on data array to plot and add colorbar, adjust label sizes
im = da_toplot.plot(ax=ax, cmap=cmap, extend='both', add_colorbar=False, add_labels=False)
cb = plt.colorbar(im,fraction= 0.02, pad= 0.04, extend='both')
cb.set_label(label = cbar_label, size=15)
cb.ax.tick_params(labelsize=12)

# set the title and coastlines
ax.set_title(title, loc='right', fontsize=20)
ax.coastlines(color='dimgray', linewidth=0.5)


# ### Do plotting with categorized colorbar, defined levels and minimum and maximum


# define upper and lower plotting limits (by default min and max of dataarray)
vmin = da.min()

vmax = da.max()

nsteps = 10

# define colorbar levels
levels = np.arange(vmin, vmax, (vmax-vmin)/nsteps)

title = 'example plot with categorized colorbar'


# define figure, projection and axes object
fig = plt.figure(figsize=(15,6))
proj=ccrs.PlateCarree()
ax = plt.subplot(111, projection=proj, frameon=False)

# do plotting based on data array to plot and add colorbar, adjust label sizes
# within plotting, define the minimum and maximum and colorbar levels
im = da_toplot.plot(ax=ax, cmap=cmap,vmin=vmin,vmax=vmax,levels=levels, extend='both', add_colorbar=False, add_labels=False)
cb = plt.colorbar(im,fraction= 0.02, pad= 0.04, extend='both')
cb.set_label(label = cbar_label, size=15)
cb.ax.tick_params(labelsize=12)

# set the title and coastlines
ax.set_title(title, loc='right', fontsize=20)
ax.coastlines(color='dimgray', linewidth=0.5)

# adjust the plotting extent based (e.g. plot Europe)
# ax.set_extent([-13, 43, 35, 70], ccrs.PlateCarree())



# you can save your figure with the figure object
fig.savefig('yourfigure.png', dpi=300)


# Up to you! Have fun while coding! 




