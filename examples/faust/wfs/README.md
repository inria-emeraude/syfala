# Experimental WFS on FPGA

* `wfs32.dsp` is our original WFS implementation (originally by Joseph Bizien). It can work with up to 4 sources on the FPGA and it is only partially accurate.
* `lecomteWFS.dsp` is inspired by a "state of the art" implementation of WFS by Pierre Lecomte. The original code can be found in `lecomteOrigWFS.dsp`. `lecomteWFS.dsp` has been adapted to be more efficient in the context of an FPGA and to support "real-world scenarios."

## Some Useful Resources for Future Research

The following resources seem to be the most up-to-date resources on WFS implementations

* Jens Ahrens' code examples from his book: <https://github.com/JensAhrens/soundfieldsynthesis/tree/master>
* SSR tool website (TU Berlin): <http://spatialaudio.net/ssr/>
* SSR documentation: <https://ssr.readthedocs.io/en/0.6.1/general.html#id1>
* SFS matlab tool documentation: <https://sfs-matlab.readthedocs.io/en/2.5.0/secondary-sources/> (meant to work in conjunction with SSR)
* SFS repo: <https://github.com/sfstoolbox/sfs-matlab/tree/master>


