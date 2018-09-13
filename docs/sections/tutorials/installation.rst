Installing PhysioZoo
====================

The PhysioZoo user interface (``PZ-UI``) can be run from Matlab or be installed as a 
standalone application. If you do not need the graphic user interface then you can 
directly download the HRV source code (``mhrv`` library). ``PZ-UI`` and ``mhrv`` 
were tested for Matlab 2016a and above running on Windows. 


PhysioZoo ``mhrv`` matlab toolbox
-------------------------------------

The PhysioZoo platform includes the ``mhrv`` matlab toolbox which implements all
the algorithmic functions required by PhysioZoo (and more). The toolbox is aimed
at researchers or developers that wish to write their own code for ECG signal
processing, HRV analysis or other applications by using the `mhrv` toolbox as a
library.

See the toolbox's :doc:`../../mhrv/sections/getting_started` page for
installation and initial setup instructions. The API reference for the toolbox
is available on this site.

The development version of the ``mhrv`` toolbox is available `here
<https://github.com/physiozoo/mhrv/>`_.

PhysioZoo ``PZ-UI`` user interface
------------------------------------

The PhysioZoo user interface (``PZ-UI``) is aimed mainly at researchers working
with physiologic data who do not wish to write any code for data analysis. It
provides many tools out of the box, all accessible from an interactive UI.

The UI can be run from Matlab or be installed as a standalone
application. ``PZ-UI`` was tested for Matlab 2016a and above
running on Windows. 

Running ``PZ-UI`` from within Matlab
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Versions supported: MATLAB 2016a and above.


1. Download or clone the source code from the `repository
   <https://github.com/physiozoo/physiozoo>`_.

2. From MATLAB launch PhysioZoo by running the script ``PhysioZoo.m`` from the
   root of the repo.

.. Note::

    The ``PZ-UI`` user interface has two modules: a ``Peak detection``
    (used to process electrophysiological signals and obtain the RR time series)
    module and a ``HRV analysis`` module (used to process the RR time series and
    compute HRV measures).


Running ``PZ-UI`` as standalone software (.exe)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Operating system: Windows 10 (and above), 64 bits.

After downloading the software from the project's `main page
<https://physiozoo.com>`_, run the ``physiozoo.exe`` file. This will start the
installation process. You can then go through the following steps.

.. note::

    Some of the screens might be slightly different depending on the version of
    Windows you are using and whether you already have the MATLAB runtime
    compiler installed. If Matlab runtime compiler is not installed then it will
    be done through this process but the installation might take some time.


1. If you get the following screen displayed then click “Run”

    .. image:: ../../_static/installation_s1.png
       :align: center

2. When the following screen is prompted then click “Next”

    .. image:: ../../_static/installation_s2.png
       :align: center

3. When the following screen is prompted then click “Next”

    .. image:: ../../_static/installation_s3.png
       :align: center

4. When the following screen is prompted check the “Yes” and then click “Next”

    .. image:: ../../_static/installation_s4.png
       :align: center

5. When the following screen is prompted then click “Install”

    .. image:: ../../_static/installation_s5.png
       :align: center

6. The installation will start. Wait until it is finished. Note that this might
   take quite some time.

    .. image:: ../../_static/installation_s6.png
       :align: center

7. When the installation is finished it will show the following screen.

    .. image:: ../../_static/installation_s7.png
       :align: center

You can now click on the **PhysioZoo** logo located on your desktop or in the list of programs.

.. image:: ../../_static/logo.png
   :align: center

