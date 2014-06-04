#!/bin/bash

echo 
echo "Please specify a path to install to:"
read tools

mkdir -p $tools
export	PATH=$tools/anaconda/bin:$tools/gdal/bin:$PATH:$tools/asp/bin
export	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$tools/gdal/lib:$tools/openjpeg-2/lib:$tools/proj/lib

# Install MiniConda Python distribution
# This will build the base directory /tools for all following software

cd $tools && \
wget --no-check-certificate \
https://github.com/PolarGeospatialCenter/asp/raw/master/originals/Miniconda/Miniconda-3.3.0-Linux-x86_64.sh && \
sh Miniconda-3.3.0-Linux-x86_64.sh -b -p $tools/anaconda && \
rm -f Miniconda*
echo y | conda install scipy=0.13.3

# Install CFITSIO
cd $tools && \
wget --no-check-certificate \
https://github.com/PolarGeospatialCenter/asp/raw/master/originals/cfitsio/cfitsio3360.tar.gz && \
tar xvfz cfitsio3360.tar.gz && \
cd cfitsio && \
./configure --prefix=$tools/cfitsio --enable-sse2 --enable-ssse3 --enable-reentrant && \
make -j && make install

# GEOS
export	SWIG_FEATURES="-I/usr/share/swig/1.3.40/python -I/usr/share/swig/1.3.40"
cd $tools && \
wget --no-check-certificate \
https://github.com/PolarGeospatialCenter/asp/raw/master/originals/geos/geos-3.4.2.tar.bz2 && \
tar xvfj geos-3.4.2.tar.bz2 && \
cd geos-3.4.2 && \
./configure --prefix=$tools/geos && \
make -j && make install 

# PROJ
cd $tools && \
wget --no-check-certificate \
https://github.com/PolarGeospatialCenter/asp/raw/master/originals/proj/proj-4.8.0.tar.gz && \
tar xvfz proj-4.8.0.tar.gz && \
cd proj-4.8.0 && \
./configure --prefix=$tools/proj --with-jni=no && \
make -j && make install

# OPENJPEG
# Change to cmake or cmake28 depending on what is installed
cd $tools && \
wget --no-check-certificate \
https://github.com/PolarGeospatialCenter/asp/raw/master/originals/openjpeg/openjpeg-2.0.0.tar.gz && \
tar xvfz openjpeg-2.0.0.tar.gz && \
cd openjpeg-2.0.0 && \
cmake -DCMAKE_INSTALL_PREFIX=$tools/openjpeg-2 && \
make install

# GDAL
# Parallel make will fail due to race conditions. Do not use -j
# GDAL 1.11 breaks sparse_disp
export	SWIG_FEATURES="-I/usr/share/swig/1.3.40/python -I/usr/share/swig/1.3.40"
cd $tools && \
wget --no-check-certificate \
http://download.osgeo.org/gdal/1.10.0/gdal-1.10.0.tar.gz && \
tar xvfz gdal-1.10.0.tar.gz && \
cd gdal-1.10.0 && \
./configure --prefix=$tools/gdal --with-geos=$tools/geos/bin/geos-config --with-cfitsio=$tools/cfitsio \
--with-python --with-openjpeg=$tools/openjpeg-2 --with-sqlite3=no && \
make && make install && \
cd swig/python && python setup.py install

export	GDAL_DATA=$tools/gdal/share/gdal

# Install Ames Stereo Pipeline
cd $tools && \
wget http://byss.ndc.nasa.gov/stereopipeline/binaries/StereoPipeline-2.4.0-x86_64-Linux-GLIBC-2.5.tar.bz2 && \
tar xvfj StereoPipeline-2.4.0-x86_64-Linux-GLIBC-2.5.tar.bz2 -C $tools && \
rm StereoPipeline*.bz2 && \
rename Stereo* asp *

echo "export	PATH=$PATH:\$PATH" >> $tools/init-asp.sh
echo "export	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:\$LD_LIBRARY_PATH" >> $tools/init-asp.sh
echo
echo	"The tools were installed in $tools."
echo	"There is an init script that sets the environment and is installed at $tools/init-asp.sh. You can source this file to run."
