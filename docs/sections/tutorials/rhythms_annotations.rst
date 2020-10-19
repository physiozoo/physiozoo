Rhythm annotations
==========

In this tutorial you will learn how to perform rhythms annotations within the **PhysioZoo** ``Peak detection`` module and how to use these for your analysis in order to provide medical diagnosis on the visualized ECG channel.


**Introduction**
----------------------

**PhysioZoo** allows you to annotate and load rhythm annotations, which contain time intervals with rhythm annotations made on the original electrophysiological signal time series. The annotations highlight parts of the RR time series segments on which a medical condition has been diagnosed by the user. The different conditions that can be annotated are: 

|	 AFIB	:	 Atrial fibrillation 
|	 AB  	:	Atrial bigeminy 
|	 AFL 	:	Atrial flutter
|	 B   	:	Ventricular bigeminy
|	 BII 	:	2° heart block
|	 IVR 	:	Idioventricular rhythm
|	 NOD 	:	Nodal (A-V junctional) rhythm 
|	 P   	:	Paced rhythm
|	 PREX	:	Pre-excitation (WPW) 
|	 SBR 	:	Sinus bradycardia 
|	 SVTA	:	Supraventricular tachyarrhythmia 
|	 T   	:	Ventricular trigeminy 
|	 VFL 	:	Ventricular flutter 
|	 VT  	:	Ventricular tachycardia 
|	 J   	:	Junctional rhythm 
|	 PAT 	:	Paroxysmal atrial tachycardia
|	 AT  	:	Atrial tachycardia
|	 IVR	:	Idioventricular rhythm 
|	 AIVR	:	Accelerated idioventricular rhythm 


**Annotating rhythms**
----------------------------
To annotate the quality of an electrophysiological signal time series, follow these steps:

	1. Select the following ECG example: File-> Open data file-> physiozoo\\ExamplesTXT\\rhythms\\ECG.txt. (the operation can be reproduced on any ECG file loaded to **PhysioZoo**)

	2. Under the record panel, select Annotation -> Rhythms. See the red rectangle on the figure below. The different options will be displayed below in the same panel. 

	3. Look for the requested segment and click on the desired rhythm. Draw the mouse on the desired segment. The background behind the selected segment will be displayed with the corresponding color.

	4. The rhythms can be exported under a .txt file and be further loaded in **PhysioZoo** to pursue the annotation process: File -> Save Rhythms file (Ctrl+T). 

.. image:: ../../_static/rhythms_interface.png
   :align: center


**Loading rhythms**
----------------------------

When using a recording for which you have performed rhythms annotations, you can load the rhythms annotations: Open -> Open rhythms file. (Ctrl+R/Click on the icon upon Rhythms file name on the left panel)

After the rhythms annotations are loaded, you will see a bar with different colors appearing on the top of the RR interval time series figure as well as on the ECG raw data. The highlighted segments correspond to the different rhythms registered in the file. The present annotations may be modified as described above. Besides, additional annotations may be inserted as well. 
On the bottom panel, statistics regarding the annotations for each condition (burden, minimal interval length, maximal interval length and 5 statistics) are displayed.

.. image:: ../../_static/rhythms_usage.png
   :align: center

