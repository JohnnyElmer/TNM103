
s.boot;
s.scope;
s.meter;
FreqScope(400,200,0, server:s);//FreqScope.new(width, height,busNum, scopeColor, bgColor, server)
//kanal 0 = vÃ¤nster, kanal 1 = hÃ¶ger
(
    SynthDef(\firstSynth, {
var output = 0.5*SinOsc.ar(220);
Out.ar(0, {output}!2); //utgÃ¥ngsbuss device 0, oscillator
    }).play;
)

(//skapa flera ljud samtidigt
    SynthDef(\twoSynths, {
var detune = 0.1; //frekvensskillnad
var sin1 = 0.5*SinOsc.ar(220+detune);
var sin2 = 0.5*SinOsc.ar(220-detune);
var sum = sin1 + sin2;
Out.ar(0, {sum}!2); //utgÃ¥ngsbuss device 0, oscillator
    }).play;
)

(//modulera frekvensen
    SynthDef(\thirdSynth, {
var sin1 = SinOsc.kr(10).range(-10,10);
//var sin1 = LFTri.kr(1).range(-10,10); //knapp skillnad, syns mer visuellt
//var sin1 = LFSaw.kr(1).range(-10,10);
//var sin1 = LFPulse.kr(1).range(-10,10);
var sin2 = SinOsc.ar(329.63 + sin1);
Out.ar(0, {sin2}!2); //utgÃ¥ngsbuss device 0, oscillator
    }).play;
)

(//testa att modulera amplituden
    SynthDef(\fourthSynth, {
var sin1 = SinOsc.kr(10).range(0,1);
var sin2 = SinOsc.ar(329.63 + sin1);
var sum = sin1 * sin2;
Out.ar(0, {sum}!2); //utgÃ¥ngsbuss device 0, oscillator
    }).play;
)

(//pulsbreddsmodulation
    SynthDef(\fifthSynth, {
//warning loud and annoying noise!!!!
var pwm = SinOsc.kr(1);//.range(0,1);
var sin2 = 0.5*LFPulse.ar(329.63,width:pwm);
Out.ar(0, {sin2}!2); //utgÃ¥ngsbuss device 0, oscillator
    }).play;
)
s.scope;
s.freqScope;
(//ringmodulation
    SynthDef(\sixthSynth, {
	var sin1 = SinOsc.ar(200);
//var sin1 = SinOsc.kr(329.63).range(-1,1);
//var sin1 = SinOsc.kr(329.63*2).range(-1,1);
//var sin1 = SinOsc.kr(329.63/2).range(-1,1);
var sin2 = SinOsc.ar(400);
var sum = sin1*sin2;
Out.ar(0, {sum}!2); //utgÃ¥ngsbuss device 0, oscillator
    }).play;//dubbla frekvens = oktav
)

(//FM-syntes
    SynthDef(\fmSynth, {
var freq1 = 200, freq2 = 329.63;
var osc1 = SinOsc.ar(freq1);//.range(0,1);
var osc2 = SinOsc.ar(osc1*freq2); //.ar(freq1*freq2);
//var osc3 = SinOsc.ar(440*osc2);
var sum = osc2;
Out.ar(0, {sum}!2); //utgÃ¥ngsbuss device 0, oscillator
    }).play;
)

(//distortion
    SynthDef(\distSynth, {
var freq1 = 1, freq2 = 329.63;
var osc1 = SinOsc.kr(freq2*freq1);//.range(0,1);
var osc2 = 0.5*LFPulse.ar(freq2); //.ar(freq1*freq2);
var sum = osc2; //.clip(-0.5,0.5);
Out.ar(0, {sum}!2); //utgÃ¥ngsbuss device 0, oscillator
    }).play;
)

(
SynthDef.new(\distSynth, { //frÃ¥ga labbhandledaren om var multiplikationen ska vara
       arg freq1=220;
       var osc2= SinOsc.ar(freq1);

       var sum=osc2.clip(-0.5, 0.5);
       Out.ar(0, {sum}!2);
    }).play;
)

(
    SynthDef.new(\accordSynth, { //med midicps och a-moll
    arg freq = 35;
	var osc2= SinOsc.ar(freq.midicps);
       Out.ar(0, {osc2}!2);
    }).add;
)



~myFirstSynth = Synth.new(\accordSynth).register;
//~myFirstSynth.set(\freq, 45);
//~mySecondSynth = Synth.new(\accordSynth).register; //Something is weird about this
(
var notes = [57, 60, 64, 69];
~myFirstSynth = Synth.new(\accordSynth).register;

fork{
    loop{
        for (0, notes.size-1, { arg index;
            ~myFirstSynth.set(\freq, notes[index]);
            0.3.wait;
        });
    }
};
)


(
SynthDef.new(\lab5_envelope_Synth, //4s lång custom attack-sustain-release
	{
		arg t_gate=0, freq=35, bufnum;
		var sig, filtered, lfo;
		var envelope = EnvGen.kr(Env.adsr(0.5, 0.3, 0, 1.0, 1, -4.0), t_gate);
		var freq2=(freq-12);

		var osc1=4*LFSaw.ar(freq.midicps); //*envelope;
		var osc2=4*LFSaw.ar(freq2.midicps);
		var mic=SoundIn.ar();
		var audioFile = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), loop:1);
		var sigkopia, sum=0;
		sig= osc1 + osc2 + (0.2*WhiteNoise.ar());
		lfo = LFSaw.kr(1).range(200,3000);

		//filtered=HPF.ar(sig, lfo)*envelope;
		//filtered=RLPF.ar(sig, lfo, 1)*envelope;
		//filtered=BPF.ar(sig, lfo, 0.5)*envelope;
		//filtered=BBandStop.ar(sig, lfo, bw:1)*envelope;
		//filtered=BLowPass4.ar(sig, 600, 0.5)*envelope;
		//filtered=BLowPass4.ar(mic*0.04, freq.midicps, 0.01)*envelope*100;
		//filtered=HPF.ar(audioFile*10, 440);
		sigkopia=sig*envelope;
		//sigkopia=audioFile*100*envelope;
		filtered=AllpassC.ar(sigkopia, decaytime:0.66 );
			sum=sigkopia+(filtered*0.6);

		3.do{
			filtered=AllpassC.ar(sigkopia, delaytime:Rand.new(lo: 0.0, hi: 1.0), decaytime:6 );
			sum=sum+(filtered*0.6);

		};

		Out.ar(0, {sum}!2);
    }).add;
)
s.meter;

(
var notes = [57, 60, 64, 69];



fork{

	var soundFileBuffer = Buffer.read(s,"/Users/Jonna/Downloads/BuzzE1.wav");
1.wait;

~myFuckedSynth= Synth.new(\lab5_envelope_Synth).register;
~myFuckedSynth.set(\bufnum, soundFileBuffer.bufnum);
    loop{
        for (0, notes.size-1, { arg index;
            ~myFuckedSynth.set(\freq, notes[index], \t_gate, 1);
            0.15.wait;
			~myFuckedSynth.set(\t_gate, 0);
			0.15.wait;
        });
    }
};
)

(
SynthDef(\noiseSynth, {
 Out.ar(0,{PinkNoise.ar()}!2);
}).play;
)


(
fork{
    loop{
        h=([33,38,40].choose.midicps)*(2**((0 .. 4).choose));
        play{
            Splay.ar({LFSaw.ar(exprand(h-(h/64),h+(h/64)),0,0.1)}!8)*LFGauss.ar(10,1/4,0,0,2);
        };
        1.wait;
    }
};
)

(
// pitch shift input - USE HEADPHONES to prevent feedback.
play({
    PitchShift.ar(
        SoundIn.ar([0, 1]),    // stereo audio input
        0.1,             // grain size
        MouseX.kr(0,2),    // mouse x controls pitch shift ratio
        0,                 // pitch dispersion
        0.004,            // time dispersion
        10 //multiplies the volume - BE CAREFUL, start with 1
    )
}))


s.quit;

