
# SynthChord

This software allows you to create or convert music using different harmonic templates for instruments


## Usage
Run GUI.jl through an ide such as visual studio to launch software


![App Screenshot](https://i.imgur.com/eTPHKlY.png)
### Song Recording
Use the keyboard in the middle to begin recording notes:   
- The rest button to the left of the keyboard allows you to add a rest to your current recording     
-  The octave box to the right of the keyboard allows you to change the current octave of the keyboard
- The note duration slider to the right of the keyboard allows you to adjust note durations in milliseconds, this duration applies to both note durations and rest durations

To listen to your song, press the play button near the bottom right of the keyboard once you are satisfied with your notes.
- The 'Select your instrument' dropdown menu above the rest button allows you to choose the instrument by which your song is played
- To reset your current recorded notes, press the reset button below the play button
### Music Conversion From File
To load a .wav file for conversion, you must first copy your desired file into the SynthChord project folder

Press the 'Load from file' button at the bottom left of the window, and enter the filename of the file you wish to convert into the pop-up window.

![App Screenshot](https://i.imgur.com/Xw594Ny.png)

Select your desired instrument from the dropdown menu and press play to listen to your converted song

### Saving Songs

To save both recorded and converted songs, simply press the 'Save as' button below the keybaord and enter your desired filename (no .wav needed at the end of filename) and press confirm, the outputted file should appear in the SynthChord project folder
![App Screenshot](https://i.imgur.com/uabp8Jc.png)

### Creating Custom Harmonic Templates

SynthChord allows you to create custom instrument harmonic templates using this area of the window:

![App Screenshot](https://i.imgur.com/y3pdCJo.png)

To adjust Attack, Decay, Sustain, and Release, simply adjust the corresponding ADSR sliders
![App Screenshot](https://i.imgur.com/Ao20vjM.png)

Then, press the 'Enter 16 Amplitudes' button and enter the 16 values into the pop-up window's entries.

To save a harmonic template, press the save button below the 'Enter 16 Amplitudes' button and enter the instrument name

The instrument should now appear in the instrument selection drop-down menu

## Tests

We have a variety of testing files within the project.

snr_test.jl: Performs the SNR test on our transcriber.

sythesizer_multiplenotes.jl: Performs envelope tests for multiple notes

synthesizer_transcriber_wrapper_test.jl: Performs the timbre and envelope alteration. To change the file transcribed to another, just enter the name of the file in the waveread.

synthesizer_waveform_tests.jl: Generates the waveform A440. The FFT portion is commented out uncomment it to see the FFT of our synthesized waveform.

transcriber_limit_tests.jl: performed basic and limit tests on our transcriber, including waveforms with rests. You can add more to the waveform generated to keep on testing the transcriber.



















#

![Logo](https://i.imgur.com/17RsASY.png)

