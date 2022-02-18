Changements par rapport à la version 2019:
(effectuer ces changements pour rendre n'importe quelle version 2019 compatible avec vivado 2020.2)

-> On appel vitis_hls à la place de vivado_hls dans le makefile
(c'est automatiquement géré dans le dernier makefile)
 
-> vivado_hls renommait automatiquement les vecteur de l'IP (ex: ap_int<24> in_left) avec un _V à la fin (ex: ap_int<24> in_left_V). Vitis_hls ne le fait pas. Pour assurer la retro compatibilité, le _V est donc ajouté dans le FPGA.cpp directement. Une autre methode aurait été de le supprimer des fichiers de compilations.
-> On traine une coquille depuis les premières versions: i2c_done n'existe pas sur le schema bloc mais il est attribué dans le master.xdc. Cela génère un critical warning. Ca n'a pas l'air d'être bloquant, mais commenter la ligne résoud le warning


