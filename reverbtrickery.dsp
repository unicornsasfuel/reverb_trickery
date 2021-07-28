declare name     "Reverb Trickery";
declare author   "Evermind";

import("stdfaust.lib");

not(x) = x <= 0;

////////////////
// UI Controls
////////////////

//"octave"
bypass_octave = not(checkbox("v:Reverb Trickery/h:[0]Trick Selection/[1]Octave"));
octave_direction = hslider("v:Reverb Trickery/t:[1]Parameters/v:[1]Octave/[0]Direction[style:menu{'Up':0;'Down':1}]",0,0,1,1);

//"distort"
bypass_distort = not(checkbox("v:Reverb Trickery/h:[0]Trick Selection/[2]Distort"));
distort_drive = hslider("v:Reverb Trickery/t:[1]Parameters/v:[2]Distort/[0]Drive",5,0,100,0.1) : /(100);

//"band"
bypass_band = not(checkbox("v:Reverb Trickery/h:[0]Trick Selection/[3]Band"));
low_cutoff = hslider("v:Reverb Trickery/t:[1]Parameters/v:[3]Band/[0]Low cutoff[unit:Hz]",20,20,20000,1);
high_cutoff = hslider("v:Reverb Trickery/t:[1]Parameters/v:[3]Band/[1]High cutoff[unit:Hz]",20000,20,20000,1);

//"gate"
bypass_gate = not(checkbox("v:Reverb Trickery/h:[0]Trick Selection/[2]Gate"));
gate_threshold = hslider("v:Reverb Trickery/t:[1]Parameters/v:[2]Gate/[0]Threshold[unit:dB]",-30,-90,0,1);
gate_attack = hslider("v:Reverb Trickery/t:[1]Parameters/v:[2]Gate/[1]Attack[unit:ms]",5,0,500,0.1) : /(1000);
gate_hold = hslider("v:Reverb Trickery/t:[1]Parameters/v:[2]Gate/[2]Hold[unit:ms]",5,0,1000,0.1) : /(1000);
gate_release = hslider("v:Reverb Trickery/t:[1]Parameters/v:[2]Gate/[3]Release[unit:ms]",5,0,1000,0.1) : /(1000);

//"bloom"

//reverb controls + wet/dry
reverb_decay = hslider("v:Reverb Trickery/t:[1]Parameters/v:[0]Reverb/[2]Sustain",50,0,100,1) : /(100);
narrowing_coefficient = 100 - hslider("v:Reverb Trickery/t:[1]Parameters/v:[0]Reverb/Narrowing %[tooltip:Adjust how much faster the stereo reverb decays. (e.g. 0 is stereo reverb, 50 is stereo reverb that fades to mono halfway through its tail, 100 is mono reverb.)]",0,0,100,1) : /(100);
wet = hslider("v:Reverb Trickery/t:[1]Parameters/v:[0]Reverb/[3]Wet %",0,0,100,1) : /(100);

//wet/dry
dry = 1-wet;

////////////////
// Process definition
////////////////

process = _,_ <: sp.stereoize(_ * dry), (effectize : reverberate(reverb_decay) : sp.stereoize(_ * wet)) :> _,_;

////////////////
// Helpers
////////////////

effectize = octave : distort : band : gate;

//"octave"
octave = ba.bypass2(bypass_octave,
                        sp.stereoize(
                            ef.transpose(
                                ba.sec2samp(.05),
                                ba.sec2samp(.05),
                                12 - (24 * octave_direction)
                            )
                        )
                    );
//"band"
band = ba.bypass2(bypass_band,
                        sp.stereoize(
                            fi.resonhp(low_cutoff, 1, 1) : fi.resonlp(high_cutoff, 1, 1)
                        )
                    );
//"gate"
gate = ba.bypass2(bypass_gate,
                        ef.gate_stereo(
                            gate_threshold,
                            gate_attack,
                            gate_hold,
                            gate_release
                        )
                    );
//"distort"
distort = ba.bypass2(bypass_distort,
                        sp.stereoize(
                            ef.cubicnl(distort_drive,0)
                        )
                    );

reverberate(decay) = _,_ <: wide_reverb(decay), narrow_reverb(decay) :> _,_ : sp.stereoize(_ * 0.5);


wide_reverb(decay) = reverb(decay * narrowing_coefficient);
narrow_reverb(decay) = reverb(decay) :> _ <: _,_;

reverb(decay) = re.dattorro_rev(0, 0.9995, .75, 0.625, decay, 0.7, 0.5, 0.0005);
//"bloom"
//wet/dry control
  