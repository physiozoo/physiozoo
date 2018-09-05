Introduction
************
**PhysioZoo** is a collaborative platform dedicated to the study of the heart rate variability (HRV) from Humans and other mammals’ electrophysiological recordings. The main components of the platform are:

- *Software*

  - An open-source algorithmic toolbox for matlab (``mhrv``), which implements all standard HRV analysis algorithms, peak detection algorithms and prefiltering routines. This can be used within your own data analysis code using the ``mhrv`` API.
    
  - An open-source graphical user interface (``PhysioZoo-UI``) that provides a user friendly interface for advanced HRV analysis of RR-intervals time series and data visualization tools. This enables easy access to HRV analysis without writing any code.

- *Databases*:

  - A set of annotated databases (dog, rabbit and mouse) of electrophysiological signals.

  - Manually audited peak locations and signal quality annotations for each recording.

- *Configuration*
  
  - A set of configuration files that adapt the HRV measures and algorithms to
    work with data from different mammals.
    
  - All HRV measures can be further adapted for the analysis of other mammals by
    creating simple human-readable mammal-specific configuration files.

  
The **PhysioZoo** mission is to standardize and enable the reproducibility of
HRV analysis in mammals’ electrophysiological data. This is achieved through
its open source code, freely available software and open access databases. It
also aims to encourage the scientific community to contribute their
electrophysiological databases and novel HRV algorithms/analysis tools for
advancing the research in the field.

Feedback on how to improve the **PhysioZoo** platform is welcomed. Do not hesitate to drop us an email at:

physiozoolab@gmail.com

Source code, data or interface enhancement contributions are welcome. Look `here <https://physiozoo.github.io/project/>`_ on how to contribute to PhysioZoo.
