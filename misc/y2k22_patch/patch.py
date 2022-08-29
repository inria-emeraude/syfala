############################################################################################
#                                                                                          #
# This script will patch Xilinx Tools for HLS Y2k22 bug                                    #
#                           Copyright (c) 2018 - 2022 Xilinx Inc.                          #
# version 1.2                                                                              #
# The patch is intended to resolve the following error                                     #
# source run_ippack.tcl -notrace                                                           #
# ERROR: '##########' is an invalid argument. Please specify an integer value.             #
# while executing                                                                          #
# "rdi::set_property core_revision "##########"                                            #
#                                                                                          #
# {component component_1}                                                                  #
# "                                                                                        #
# invoked from within                                                                      #
# "set_property core_revision $Revision $core"                                             #
# (file "run_ippack.tcl" line 835)                                                         #
#                                                                                          #
# The root cause for the issue is in run_ippack.tcl called by export_ip.tcl.               #
# set Revision "##########"                                                                # 
# set_property core_revision $Revision $core                                               #
#                                                                                          #  
# For more information see:                                                                #
# https://support.xilinx.com/s/article/76960                                               #
############################################################################################

import os, sys, datetime, shutil, glob, re

version='1.2'
today = datetime.date.today()
today = datetime.date.strftime(today, "%Y-%m-%d")

log_file = open("y2k22_patch.log", "a+")
def log(msg, lvl='INFO'):
    if 'DEBUG' in lvl and not os.environ.get('DEBUG_LOG'):
        return
    msg='[%s] %s: %s' %(today,lvl,msg)
    print(msg)
    log_file.write('%s\n' %msg)
    log_file.flush()

valid_rels=['2014.*','2015.*','2016.*','2017.*','2018.*','2019.*','2020.*','2021.*']


formatted_rels=''
for rel in valid_rels:
    formatted_rels+='%s, ' %rel
formatted_rels= formatted_rels[:-2]
k = formatted_rels.rfind(", ")
formatted_rels=formatted_rels[:k] + " and" + formatted_rels[k+1:]
log("This script (version: %s) patches Xilinx Tools for HLS Y2k22 bug for the following release: \n\t\t%s" %(version,formatted_rels) )
# log("Script version %s is targeted for %s releases " %(version,formatted_rels))

install_root = os.getcwd()

filePath='%s/*/%s/common/scripts/automg.tcl'
if os.environ.get("INSTALL_PATH"):
    install_root=os.environ.get("INSTALL_PATH")
dry_Run=False
if os.environ.get('DRY_RUN'):
  dry_Run=os.environ.get('DRY_RUN') == 'True'

def do_copy(src,dest):
  '''
  pure copy, no manipulation
  '''
  src=src.strip()
  if not os.path.exists(src):
    log("%s does not exists" %src, "IGNORED")
  dest=dest.strip()
  if os.path.isdir(dest) :
      dest=os.path.join(dest,os.path.basename(src))
  if dry_Run:
    log("Won't copy %s  to %s " % (src,dest),"DRYRUN")
    return
  log("%s  to %s " % (src,dest),"COPY")
  try:
      shutil.copyfile(src,dest)
      try:
          os.chmod(dest, 0o755)
      except Exception as e:
          log("Unable to change file permission for %s\n%s" %(dest,e),"WARNING")
          pass
  except:
      pass


for rel in valid_rels:
  path=filePath % (install_root,rel)
  for file in glob.glob(path):
      dir=os.path.dirname(file)
      log("%s" %dir, "UPDATE")
      do_copy("%s/y2k22_patch/automg_patch_20220104.tcl"%os.getcwd(),dir)

        


