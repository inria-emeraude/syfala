#!/usr/bin/env bash

slon="PHN2ZyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHdpZHRoPScyNCcgaGVpZ2h0PScyNCcgdmlld0JveD0nMCAwIDM3MCAzNzAnPjxwYXRoIGQ9J00yNzMgODhIOTdjLTUzLjUgMC05NyA0My42LTk3IDk3czQzLjUgOTcgOTcgOTdoMTc2YzUzLjUgMCA5Ny00My42IDk3LTk3cy00My41LTk3LTk3LTk3em0tMTE3LjYgOTdjMCAyOC44LTIzLjQgNTIuMi01Mi4yIDUyLjItMjguOCAwLTUyLjItMjMuNC01Mi4yLTUyLjIgMC0yOC44IDIzLjQtNTIuMiA1Mi4yLTUyLjIgMjguOCAwIDUyLjIgMjMuNCA1Mi4yIDUyLjJ6JyB0cmFuc2Zvcm09J3RyYW5zbGF0ZSgzNzAsIDApIHNjYWxlKC0xLCAxKScgZmlsbD0nZ3JlZW4nIC8+PC9zdmc+Cg=="
sloff="PHN2ZyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHdpZHRoPScyNCcgaGVpZ2h0PScyNCcgdmlld0JveD0nMCAwIDM3MCAzNzAnPjxwYXRoIGQ9J00yNzMgODhIOTdjLTUzLjUgMC05NyA0My42LTk3IDk3czQzLjUgOTcgOTcgOTdoMTc2YzUzLjUgMCA5Ny00My42IDk3LTk3cy00My41LTk3LTk3LTk3em0tMTE3LjYgOTdjMCAyOC44LTIzLjQgNTIuMi01Mi4yIDUyLjItMjguOCAwLTUyLjItMjMuNC01Mi4yLTUyLjIgMC0yOC44IDIzLjQtNTIuMiA1Mi4yLTUyLjIgMjguOCAwIDUyLjIgMjMuNCA1Mi4yIDUyLjJ6JyBmaWxsPSdncmV5JyAvPjwvc3ZnPgo="
#sloffRED="PHN2ZyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHdpZHRoPScyNCcgaGVpZ2h0PScyNCcgdmlld0JveD0nMCAwIDM3MCAzNzAnPjxwYXRoIGQ9J00yNzMgODhIOTdjLTUzLjUgMC05NyA0My42LTk3IDk3czQzLjUgOTcgOTcgOTdoMTc2YzUzLjUgMCA5Ny00My42IDk3LTk3cy00My41LTk3LTk3LTk3em0tMTE3LjYgOTdjMCAyOC44LTIzLjQgNTIuMi01Mi4yIDUyLjItMjguOCAwLTUyLjItMjMuNC01Mi4yLTUyLjIgMC0yOC44IDIzLjQtNTIuMiA1Mi4yLTUyLjIgMjguOCAwIDUyLjIgMjMuNCA1Mi4yIDUyLjJ6JyBmaWxsPSdyZWQnIC8+PC9zdmc+Cg=="


project_directory=/home/maxime/faust_workspace/syfala-project
plugin_directory=~/.config/argos



if pidof -x "syfala" >/dev/null; then
	#"Process already running"
	isRunning=1
else
	isRunning=0
fi
status=$(tail -2  $project_directory/syfala_log.txt | head -1 | cut -d "]" -f2 | cut -b-30)

if [ -f "$plugin_directory/syfala.+.sh" ]; then
#autorefresh disable
	submenu="--"
	echo "SyFaLa"
else
	submenu=""
	if [[ $status == " Successful run!" ]]; then	
		echo "SyFaLa: <span color='green'>DONE!</span>"
	elif [ $isRunning == "1" ]; then	
		echo "SyFaLa: <span color='yellow'>RUNNING...</span> "
	elif [[ $isRunning == "0" && -d "$project_directory/build" ]]; then	
		echo "SyFaLa: <span color='red'>FAILED</span> "
	else
		echo "SyFaLa: <span color='cyan'>CLEAN</span> "
	fi
fi


echo "---"

if [ "$ARGOS_MENU_OPEN" == "true" ]; then


echo "SyFaLa Project | iconName=terminal bash='cd $project_directory  ; neofetch' terminal=true"
echo "---"
if [ -d "$project_directory/build" ]; then

	ip_exist=$(grep -q "Generated output file" "$project_directory/build/vitis_hls.log" ; echo $?) #2: donesn't exist, 1: failed; 0: Success!
	project_exist=$(grep -q "Successfully created Hardware Platform" "$project_directory/build/vivado.log" ; echo $?) #2: donesn't exist, 1: failed; 0: Success!
	if [ -d "$project_directory/build/syfala_application" ]; then
		if [ -f "$project_directory/build/sw_export/application.elf" ]; then
			app_exist=0 #0: Success!
		else
			app_exist=1 #1: failed
		fi
	else
			app_exist=2 #2: donesn't exist
	fi
	
	
	if [[ $ip_exist == "0" && $project_exist == "0" && $app_exist == "0" ]]; then
		full_date=$(tail -1 "$project_directory/build/vivado.log" |rev| cut -b8-23 | rev) #We display the project date
		echo "<span font-weight='bold'>Build State</span> [<span color='green' font-weight='bold'><tt>DONE</tt></span>] \n<span color='gray' font-weight='light'>$full_date</span>"
	else
		if [ $isRunning == "1" ]; then
			echo "<span font-weight='bold'>Build State</span> [<span color='orange' font-weight='bold'><tt>RUNNING...</tt></span>]"
		else
			echo "<span font-weight='bold'>Build State</span> [<span color='orange' font-weight='bold'><tt>PART.</tt></span>]"
		fi
	fi
	
	if [ $ip_exist == "0" ]; then
		ip_date=$(tail -1 "$project_directory/build/vitis_hls.log" |rev| cut -b8-23 | rev)
		echo "$submenu   IP                         [<span color='green' font-weight='bold'><tt>DONE</tt></span>] \n   <span color='gray' font-weight='light'>$ip_date</span> | trim=false"
	elif [ $ip_exist == "1" ]; then
		if [ $isRunning == "1" ]; then
			echo "$submenu   IP                         [<span color='orange' font-weight='bold'><tt>RUN...</tt></span>] | trim=false"
		else
			echo "$submenu   IP                         [<span color='orange' font-weight='bold'><tt>FAILED</tt></span>] | trim=false"
		fi
	else
			echo "$submenu   IP                         [<span color='red' font-weight='bold'><tt>CLEAR</tt></span>] | trim=false"
	fi


	if [ $project_exist == "0" ]; then
		project_date=$(tail -1 "$project_directory/build/vivado.log" |rev| cut -b8-23 | rev)
		echo "$submenu   Projet               [<span color='green' font-weight='bold'><tt>DONE</tt></span>] \n   <span color='gray' font-weight='light'>$project_date</span> | trim=false"
	elif [ $project_exist == "1" ]; then
		if [ $isRunning == "1" ]; then
			echo "$submenu   Projet               [<span color='orange' font-weight='bold'><tt>RUN...</tt></span>] | trim=false"
		else
			echo "$submenu   Projet               [<span color='orange' font-weight='bold'><tt>FAILED</tt></span>] | trim=false"
		fi
	else
		echo "$submenu   Projet               [<span color='red' font-weight='bold'><tt>CLEAR</tt></span>] | trim=false"
	fi
	
	if [ $app_exist == "0" ]; then
		app_date=$(ls -l  --time-style locale "$project_directory/build/sw_export/application.elf" |rev| cut -b76-91 | rev)
	echo "$submenu   Application   [<span color='green' font-weight='bold'><tt>DONE</tt></span>] \n   <span color='gray' font-weight='light'>$app_date</span> | trim=false"
	elif [ $app_exist == "1" ]; then
		if [ $isRunning == "1" ]; then
			echo "$submenu   Application   [<span color='orange' font-weight='bold'><tt>RUN...</tt></span>] | trim=false"
		else
			echo "$submenu   Application   [<span color='orange' font-weight='bold'><tt>FAILED</tt></span>] | trim=false"
		fi
	else
	echo "$submenu   Application   [<span color='red' font-weight='bold'><tt>CLEAR</tt></span>] | trim=false"
	fi
else
	echo "Build State   [<span color='red' font-weight='bold'><tt>CLEAN</tt></span>]"
fi
echo "$submenu<tt>relaunch</tt> | iconName=view-refresh bash='cd $project_directory; syfala clean; syfala examples/virtualAnalog.dsp |& tee syfala_all.log'"
if [ $isRunning == "1" ]; then	
  state=$(tail -1  $project_directory/syfala_log.txt | cut -d "]" -f2 | cut -b-30)
	echo "<tt>$state</tt>"
fi
echo "---"
echo "Software"
echo "--   Vitis HLS| bash=vitis_hls terminal=false trim=false"
echo "--   Vivado| bash=vivado terminal=false trim=false"
echo "--   Vitis| bash=vitis terminal=false trim=false"
echo "---"
if [ -f "$plugin_directory/syfala.+.sh" ]; then
	echo "Auto Refresh | refresh=true terminal=false bash='mv ~/.config/argos/syfala.+.sh ~/.config/argos/syfala.1s+.sh' image=$sloff "
else
	echo "Auto Refresh | refresh=true terminal=false bash='mv ~/.config/argos/syfala.1s+.sh ~/.config/argos/syfala.+.sh' image=$slon"
fi
else
  echo "Loading..."
fi

