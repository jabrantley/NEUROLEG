# NEUROLEG

For part of my PhD dissertation project, I developed a real-time EEG-based brain-machine interface that was used by lower limb amputees to control a custom powered-knee prosthesis. We recruited several below-the-knee amputees to participate in a two parts study: an offline study that used EEG, EMG, IMU-based motion capture, and fMRI to study the representation of the phantom limb; and a second study that focused on EEG-based closed-loop control. This was an exciting project and we hope to publish the detailed protocol and results soon! This repo provides the source code for the real-time EEG-based BMI. Here is a basic overview of the experiment/program:

- The subject was instrumented with EEG, EMG, IMUs, and goniometers. 
- They were seated in front of a monitor where they performed a series of movement tasks according to the cues and timing presented on the screen. These included movements of the intact and phantom knee and bilateral hand movements as a control. 
- For realtime experiments, the subject performed a series of training trials where they followed the path of the moving dot. 
- A Kalman filter was trained to predict the position of their limb from the EEG and EMG signals.
- The subjects were given a few trials to perform EMG-control of the device. 
- After several trials, the control was shifted from EMG to EEG control.

The real-time interface was developed using MATLAB since several of the key components were already written there. The main GUI is `/rtc/NEUROLEG_GUI.m`, which was used to set up the experiment parameters and call all of the required functions. 

```bash   
.
├── _inprogress           # Functions currently in progress
├── dependencies          # Contains a few dependencies. Some may be unneeded but needs to be double checked
├── images                # Images/videos. Mostly for demonstration purposes
├── misc                  # Contains EEG montage
├── ...
├── rtc                                                # CONTAINS ALL THE CODE FOR REAL TIME CONTROL (RTC)
│   ├── NEUROLEG_GUI.fig                               # Figure file for MATLAB GUI - built with GUIDE
│   ├── NEUROLEG_GUI.m                                 # Main GUI for running real time 
│   ├── Neuroleg_Movement_Demo.m                       # Demo file
│   ├── Neuroleg_PIDcontrol_JB                         # PID control in Arduino for leg prosthesis
│   ├── Neuroleg_RTControl_Demo.m                      # Demo file RTC
│   ├── XBee_TriggerBox_MAIN_PsychtoolboxProtocol_JB   # Arduino code for trigger box used to sync systems
│   ├── ...
│   └── neuroleg_gui_functions                         # RTC CODE CALLED BY NEUROLEG_GUI
├── ...
└── utils                                              # CONTAINS KALMAN FILTER, BW FILTER, CLEANING FUNCTIONS, ETC..
```
For clarity, I want to break down a few of the folders in more detail. After running `/rtc/NEUROLEG_GUI.m`, the following scripts are called in order:

```bash   
.
├── ...
├── rtc
│   ├── ...
│   └── neuroleg_gui_functions 
│       └── ... description below ...
```

| Function      | Purpose | Notes     |
| :---        |    :----   |          ---: |
| `neuroleg_realtime_setup`      | Set defaults     |     |
| `neuroleg_realtime_params2handles`      | Set defaults     |     |
| `neuroleg_realtime_parsehandles`      | Set defaults     |     |
| `build_movement_fig`      | Set defaults     |     |
| `neuroleg_realtime_stream`      | Set defaults     | Run for each leg - used to get training data  |
| `neuroleg_realtime_train`      | Set defaults     |     |



│       ├── OnLineInterface64.h                        # For streaming Biometrics data to MATLAB
│       ├── WindowAPI.c                                # 
│       ├── WindowAPI.m                                # For controlling window
│       ├── build_movement_fig.m                       # Used to build figure window to show stimulus
│       ├── make_movement_pattern.m                    # Defines sinusoidal movement pattern for stimulus
│       ├── neuroleg_realtime_control.m                # Used to control 
│       ├── neuroleg_realtime_freemove.m
│       ├── neuroleg_realtime_main.m
│       ├── neuroleg_realtime_params2handles.m
│       ├── neuroleg_realtime_parsehandles.m
│       ├── neuroleg_realtime_processing.m
│       ├── neuroleg_realtime_processing_HINFthenFILT.m
│       ├── neuroleg_realtime_setup.m
│       ├── neuroleg_realtime_stream.m
│       ├── neuroleg_realtime_train.m
│       ├── pnet.mexw64
│       └── uTest_WindowAPI.m
└── utils
    ├── KalmanFilter.m
    ├── KernelRidgeRegression.m
    ├── Orientation_Estimation.m
    ├── align_data.m
    ├── biometrics_datalog.m
    ├── blindcolors.m
    ├── filterdata.m
    ├── hinfinity.m
    ├── keepvars.m
    ├── loadBiometrics.m
    ├── loadOpal.m
    ├── loadbvef.m
    ├── make_ss_filter.m
    ├── readcaptrak.m
    ├── resampledata.m
    ├── rescale_data.m
    ├── savefile.m
    └── use_ss_filter.m

| Function      | Purpose | Test Text     |
| :---        |    :----:   |          ---: |
| Header      | Title       | Here's this   |
| Paragraph   | Text        | And more      |



Here is an example of the offline experiments where the subject is moving the intact limb:

<video width="50%" loop autoplay controls src="https://user-images.githubusercontent.com/22403383/159746338-ea9febbc-a2d1-4504-a2ab-f951ec210ce0.mp4" type="video/mp4">
    Your browser does not support the video tag.
</video>

And here is an example of the subject moving the phantom limb. Notice the small movements of the stump. 

<video width="50%" loop autoplay controls src="https://user-images.githubusercontent.com/22403383/159745693-2a565167-ee54-4d81-925e-2f6627f1f075.mp4" type="video/mp4">
    Your browser does not support the video tag.
</video>


