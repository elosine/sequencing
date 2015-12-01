(
~wtb1  = Buffer.read(s, "/Users/jyang/GitHub/wavetablesynthesis/wavetables/WT7.aif");
~wtb2 = Buffer.read(s, "/Users/jyang/GitHub/wavetablesynthesis/wavetables/WT10.aif");

SynthDef( \lead_seq, {
	arg dur=0.5, trig=1, atk=0.03, rel=1.5, crv = 0,
	ffreqhi=15000, ffreqlo=100,
	fatk=0.01, fdecay= 1.2, fsusl=0.18, frel=1, fcrv= -2,
	osamp1=0.5, osamp2=0.5, osamp3=1,
	detune1= -0.08, detune2= 0.08, detune3=0.02,
	lfo1w=3, lfo1freq=45, lfo2freq = 6, lfo3freq = 0.1,
	glide=0.7, wtbuf, offset=0.65;
	var osc1, freq1, pitch1;
	var osc2, freq2, pitch2;
	var osc3, freq3, pitch3;
	var pch, amp;
	var sig, sig2;
	var env, fenv;
	var lfo1, lfo2, lfo3;
	//Envelopes
	env = EnvGen.ar( Env.linen(atk, dur, rel, 1, crv), trig );
	fenv = EnvGen.ar( Env.adsr(fatk, fdecay, fsusl, frel, curve:fcrv), trig );
	//lfos
	lfo1 = SinOsc.kr(lfo1freq*fenv);
	lfo2 = SinOsc.kr(lfo2freq);
	lfo3 = SinOsc.kr(lfo3freq);
	//Pitch/Frequency/Amp
	pch = \pitch.kr(60, glide);
	pitch1 = pch + (lfo2*detune1);
	pitch2 = pch + (lfo2*detune2);
	pitch3 = pch + (lfo3*detune3);
	freq1 = pitch1.midicps;
	freq2 = pitch2.midicps;
	freq3 = pitch3.midicps;
	amp = \amp.kr(0.85, 0.017);
	//Oscillators
	osc1 = Saw.ar(freq1);
	osc2 = Saw.ar(freq2);
	osc3  = VOsc3.ar(wtbuf+offset, freq3, freq3+0.37, freq3+0.43, 0.3333);
	//Mix-Filter-Make Stereo
	sig = Mix.ar( [osc1*osamp1, osc2*osamp2, osc3*osamp3] );
	sig = RLPF.ar(sig, (((ffreqhi*fenv)+ffreqlo).cpsmidi+(lfo1*lfo1w)).midicps );
	sig2 = DelayC.ar(sig, 0.2, 0.05);
	Out.ar(0, [sig, sig2]*amp*env);
}).add;
)

(
 Pbind(
  \instrument, \lead_seq,
  \pitch,  Pseq( #[  52, 52, 52, 47, 55, 52, 47, 55, 52, \rest  ], inf ),
  \dur,  Pseq( [ 1, 1, 1, 0.75, 0.25, 1, 0.75, 0.25, 1, 1 ], 2 ),
  \amp,  Pseq( [ 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0 ], 2 )
 ).play
)
