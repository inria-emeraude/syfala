This directory contains all kind testbenches to simulate vhdl program.

Tested on 04/2021:

# testbench_vivado_hls_Faust explain how C/RTL simulation can be done with vivado_hls to validate the behaviour of a vivado_hls IP

## 04/2021 Ca marche chez moi en suivant les indication du README.txt (pas en utilisant le Makefile), mais en utilisant vivado_hls 2019.1

## TODO: C'est un test avec un cpp très simple, je vais essayer de le passer sur 2020.2 et après on pourra tester l'IP sinwave.


# testbench_ghdl_I2S uses vhdl to simulate (an old version of) the I2S transceiver and shows how to use file to read input samples.

## 04/2021 Ca marche chez moi (make et make view, mais c'est l'ancienne version d'I2S donc inutile pour nous)

Ma version de ghdl 1.0-dev, il semblerait que je l'ai installée a partir des sources:

I2S$ ghdl --version
GHDL 1.0-dev (v0.37.0-283-gbc269c6a) [Dunoon edition]
 Compiled with GNAT Version: 7.5.0

# testbench_faust_vivado_HLS_v3

Marche chez moi, permet uniquement de vérifier que la sortie de faust_v3.cpp est la même qu'un fichier en dur (debug-440.000000), donc pas très utile mais on peut sans doute réutiliser le testbench qui écrit dans un fichier les sorties de faust.

# testbenches_vivado    This directory contains several sub-directories to finally simulate the real behaviour of the whole design on chip (not complete now)

## testbenches_vivado/testbench_ghdl_emul_faust

Marche chez moi, permet de valider une "fausse" IP faust qui permet de débugger l'I2S ensuite

## testbenches_vivado/testbench_ghdl_new_I2S

Marche chez moi après correction, ca valide l'I2S mais je ne comprend pas trop parce que ce n'est pas le même I2S qu'on utilise dans le repertoire src... A voir si on remplace par le nouveau (donc ne pas utiliser ce test pour l'instant)

## testbenches_vivado/testbench_ghdl_both_I2S_emul_faust

Marche chez moi (j'ai du rajouter dans le git  le i2s_transceiver.vhd), tout est OK: l'I2S actuel fonctionne avec l'emul faust (qui fait passer une entrée vers la sortie)

## testbenches_vivado/testbench_vivado_I2S_faust_v4

marche chez moi mais avec vivado 2019.1 et faust  2.27.2, il faut suivre le readme très précisément, ca permet de simuler l'ensemble faust_v4 + I2S avec un program très simple (sawtooth en attachement). ce qu'on voit (cf png) c'est que la donnée sur la voie de droite n'est disponible qu'un cycle alors que la donnée sur la voie de gauche est disponible longtemps, ca explique peut-être les problèmes  qu'on a entre voie droite et gauche.
