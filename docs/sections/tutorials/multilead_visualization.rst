Multi-lead visualization
==========

In this tutorial you will learn how to visualize up to 3 ECG leads within the **PhysioZoo** ``Peak detection`` module and how to use these and reproduce a Holter review setting. 


**Introduction**
----------------------

**PhysioZoo** allows you to visualize up to 3 ECG leads in parallel. The visualization of several ECG leads is needed in most cases to evaluate properly the presence of a given cardiac condition. This tutorial will show how to display several channels in parallel.


**Displaying several leads**
----------------------------
To display several leads of an electrophysiological signal time series, follow these steps:

	1. Select the multi-lead ECG example: File-> Open data file-> physiozoo\\ExamplesTXT\\multi-lead\\multi-lead.txt. (the operation can be reproduced on any ECG file loaded to **PhysioZoo**)

	2. On the right panel, select the desired channels to be displayed. By default, only channel 1 is selected. 

	3. The navigation and the additional **PhysioZoo** tools still are available under this multi-lead mode. 

.. image:: ../../_static/multi-lead.png
   :align: center

   
**Frequently asked questions**
----------------------------

**What is the format of the files to be loaded to **PhysioZoo** to display several leads ?**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The files can be under the .mat format. Each column will represent a different lead. An other option is to use a .txt file which will contain the following header: 

|	---
|	Mammal:            **Mammal type (human, rabbit...)**
|	Fs:                **Sampling frequency**
|	Integration_level: electrocardiogram
|	
|	Channels:
|	
|	    - type:   electrography
|	      name:   **Channel name**
|	      unit:   **Units (usually mV)**
|	      enable: yes
|	 
|	    - type:   electrography
|	      name:   **Channel name**
|	      unit:   **Units (usually mV)**
|	      enable: yes
|	
|	    - type:   electrography
|	      name:   **Channel name**
|	      unit:   **Units (usually mV)**
|	      enable: yes
|	---
|	
| Following this header, the user shall place the samples in 3 distinct columns, separated by a space. The user is invited to open the 'multi-lead.txt' example to visualize the structure of the file. 