from pprint import pprint as pretty_print
from rich.panel import Panel
from platform import system
from .utils import _banner
from pathlib import Path
from typing import Optional, List
import inquirer
import os

try:
    XILINX_ROOT_DIR = os.environ["XILINX_ROOT_DIR"]
except KeyError:
    XILINX_ROOT_DIR = None

POSSIBLE_KEYS = {
    # XILINX RELATED OPTIONS
    "XILINX_ROOT_DIR": XILINX_ROOT_DIR,
    "XILINX_VERSION": "2022.2",
    # TARGET
    "TARGET": "faust",
    # TARGET FAUST
    "FAUST":"faust",
    "FAUST_MCD": "16",
    "FAUST_DSP_TARGET": "examples/bypass.dsp",
    "FAUST_HLS_ARCH_FILE": "source/rtl/hls/faust_dsp_template.cpp",
    "FAUST_ARM_ARCH_FILE": "include/syfala/arm/faust/control.hpp",
    # TARGET CPP
    "HLS_CPP_SOURCE": "source/rtl/hls/template_fir.cpp",
    "HOST_MAIN_SOURCE": "source/arm/baremetal/arm.cpp",
    "INPUTS": "0",
    "OUTPUTS": "0",
    # BOARD TARGET
    "BOARD": "Z20",
    "BOARD_CONSTRAINT_FILE": "source/constraints/zybo.xdc", # for zybo
    # RUNTIME PARAMETERS
    "SAMPLE_RATE": "48000",
    "SAMPLE_WIDTH": "24",
    "MULTISAMPLE": "0",
    "MEMORY_TARGET": "DDR",
    "CONTROLLER_TYPE": "PCB1",
    "CTRL_MIDI": "FALSE",
    "CTRL_OSC": "FALSE",
    "CTRL_HTTP": "FALSE",
    # ADVANCED BUILD OPTIONS
    "LINUX": "FALSE",
    "CONFIG_EXPERIMENTAL_TDM": "FALSE",
    "CONFIG_EXPERIMENTAL_SIGMA_DELTA": "FALSE",
    "PREPROCESSOR_HLS": "FALSE",
    "PREPROCESSOR_I2S": "FALSE",
    "I2S_SOURCE": "source/rtl/i2s/i2s_template.vhd",
    "BD_TARGET": "source/bd/standard.tcl",
}


# Find the project directory located in the home directory + syfala-project


class Tui:
    def __init__(self, config: Path):
        print(_banner)
        self.config_path = config
        self.config_file: Optional[dict] = None
        self.run_commands: str = "make all"
        try:
            self.config_file: dict = self._read_config_file(self.config_path)
        except FileNotFoundError or Exception as e:
            self.config_file: dict = self._create_template_makefile_env()

    def _create_template_makefile_env(self, config_file_path: Path | str) -> None:
        """If the makefile.env file does not exist, create a template file.
        The template file will be created in the default syfala-project
        directory. If the directory does not exist, it will be created.

        Args:
            config_file_path (Path | str): Path to the makefile.env file
        """
        if config_file_path.exists() and config_file_path.is_file():
            return
        else:
            print(
                "====> Creating makefile.env file (and possibly syfala-project directory)"
            )
            try:
                if not config_file_path.parent.exists():
                    config_file_path.parent.mkdir(parents=True)
                    config_file_path.touch()
                else:
                    config_file_path.touch()
            except Exception as e:
                raise Exception(f"Could not create makefile.env file: {str(e)}")
        return self._parse_makefile_env(config_file_path)

    def _parse_makefile_env(self, file_path: Path | str) -> dict:
        """Parse the makefile.env file and return a dictionary with the
        variables and their values. If the file does not exist, return
        an empty dictionary.

        Args:
            file_path (Path | str): Path to the makefile.env file

        Returns:
            dict: Dictionary containing the config variables and their values
        """
        variables = {} | POSSIBLE_KEYS
        try:
            with open(file_path, "r") as file:
                for line in file:
                    line = line.strip()
                    if line:
                        if not line.startswith("#") and ":=" in line:
                            var, value = line.split(":=")
                            if var.strip() in POSSIBLE_KEYS.keys():
                                variables[var.strip()] = value.strip()
                            else:
                                print(
                                    f"====> Unknown variable in config file: {var.strip()}"
                                )
        except FileNotFoundError:
            variables = self._create_template_makefile_env(file_path)

        # Return dictionary whose values are not None
        return {key: value for key, value in variables.items() if value is not None}

    def _read_config_file(self, makefile_env_path) -> dict:
        """Entry point for reading the makefile.env file. This function
        will try to parse the makefile.env file and return a dictionary

        Args:
            makefile_env_path (_type_): Path to the makefile.env file

        Raises:
            Exception: Exception raised if the makefile.env file
            could not be parsed. Note that the program will try
            to create a template makefile.env file if it does not
            exist or is invalid.

        Returns:
            dict: Dictionary containing the syfala config variables and their values
        """
        return self._parse_makefile_env(makefile_env_path)

    def _display_config_file(self,  config_file: dict) -> None:
        """Entry point for displaying the makefile.env file. This function
        will try to parse the makefile.env file and return a dictionary

        Args:
            makefile_env_path (_type_): Path to the makefile.env file

        """
        for key, value in config_file.items():
            print(f"[#] {key} : {value}")
        print("\n")
        self._main_menu()

    
    def _xilinx_related_options_menu(self, config_file: dict) -> None:
        """Xiling related options menu. This menu will allow the user
        to modify the Xilinx related options in the makefile.env file.

        Args:
            config_file (dict): The syfala config file
        """
        answer = inquirer.prompt(
            [
                inquirer.Text(
                    "XILINX_ROOT_DIR",
                    message="Xilinx root directory",
                    default=config_file.get("XILINX_ROOT_DIR", None),
                ),
                inquirer.List(
                    "XILINX_VERSION",
                    message="Xilinx Version?",
                    choices=[2020.2, 2022.2],
                    default=2022.2,
                ),
            ]
        )
        self.config_file = self.config_file | answer
        self._variables_menu(self.config_file)

    def _target_menu(self, config_file: dict) -> None:
        """The target menu will allow the user to choose between the Faust
        or C++ target. Depending on the target, a sub-menu will be displayed

        Args:
            config_file (dict): The Syfala config file
        """
        answer = inquirer.prompt(
            [
                inquirer.List(
                    "menu", message="What targets?", choices=["Faust", "C++"]
                ),
            ]
        ).get("menu", None)

        if answer == "Faust":
            self.config_file["TARGET"] = "faust"
            faust_options = inquirer.prompt(
                [
                    inquirer.Text(
                        "FAUST",
                        message="Faust PATH",
                        default=config_file.get("FAUST", None),
                    ),
                    inquirer.Text(
                        "FAUST_MCD",
                        message="Faust MCD PATH",
                        default=config_file.get("FAUST_MCD", None),
                        validate=lambda _, x: int(x) % 2 == 0,
                    ),
                    inquirer.Text(
                        "FAUST_DSP_TARGET",
                        message="Faust DSP target",
                        default=config_file.get("FAUST_DSP_TARGET", None),
                    ),
                    inquirer.Text(
                        "FAUST_HLS_ARCH_FILE",
                        message="Faust HLS arch file",
                        default=config_file.get("FAUST_HLS_ARCH_FILE", None),
                    ),
                    inquirer.Text(
                        "FAUST_ARM_ARCH_FILE",
                        message="Faust ARM arch file",
                        default=config_file.get("FAUST_ARM_ARCH_FILE", None),
                    ),
                ]
            )
            self.config_file = self.config_file | faust_options
            self._variables_menu(self.config_file)

        elif answer == "C++":
            self.config_file["TARGET"] = "cpp"
            cpp_options = inquirer.prompt(
                [
                    inquirer.Text(
                        "HLS_CPP_SOURCE",
                        message="HLS CPP source",
                        default=config_file.get("HLS_CPP_SOURCE", None),
                    ),
                    inquirer.Text(
                        "HOST_MAIN_SOURCE",
                        message="Host main source",
                        default=config_file.get("HOST_MAIN_SOURCE", None),
                    ),
                    inquirer.Text(
                        "INPUTS",
                        message="Inputs",
                        default=config_file.get("INPUTS", None),
                        validate=lambda _, x: x.isnumeric() and int(x) >= 0,
                    ),
                    inquirer.Text(
                        "OUTPUTS",
                        message="Outputs",
                        default=config_file.get("OUTPUTS", None),
                        validate=lambda _, x: x.isnumeric() and int(x) >= 0,
                    ),
                ]
            )
            self.config_file = self.config_file | cpp_options
            self._variables_menu(self.config_file)

    def _board_target_menu(self, config_file: dict) -> None:
        """This menu will allow the user to modify the board target.
        The board target is the FPGA board that will be used for the
        build.

        Args:
            config_file (dict): The Syfala config file
        """
        board_options = inquirer.prompt(
            [
                inquirer.List(
                    "BOARD", message="What board?", choices=["Z10", "Z20", "GENESYS"]
                ),
                inquirer.Text(
                    "BOARD_CONSTRAINT_FILE",
                    message="Board constraint file",
                    default=config_file.get("BOARD_CONSTRAINT_FILE", None),
                ),
            ]
        )
        self.config_file = self.config_file | board_options
        self._variables_menu(self.config_file)

    def _runtime_parameters_menu(self, config_file: dict) -> None:
        """This menu will allow the user to modify the runtime parameters
        of the build. The runtime parameters are the parameters that determine
        how the FPGA will behave at runtime.

        Args:
            config_file (dict): The Syfala config file
        """
        runtime_parameters = inquirer.prompt(
            [
                inquirer.List(
                    "SAMPLE_RATE",
                    message="Sample rate",
                    choices=[24000, 44100, 48000, 96000, 192000, 384000, 768000],
                    default=config_file.get("SAMPLE_RATE", None),
                ),
                inquirer.List(
                    "SAMPLE_WIDTH",
                    message="Sample width",
                    choices=[16, 24, 32],
                    default=config_file.get("SAMPLE_WIDTH", None),
                ),
                inquirer.Text(
                    "MULTISAMPLE",
                    message="Multisample",
                    default=config_file.get("MULTISAMPLE", None),
                    validate=lambda _, x: x.isnumeric() and int(x) % 2 == 0,
                ),
                inquirer.List(
                    "MEMORY_TARGET",
                    message="Memory target",
                    choices=["STATIC", "DDR"],
                    default=config_file.get("MEMORY_TARGET", None),
                ),
                inquirer.List(
                    "CONTROLLER_TYPE",
                    message="Controller type",
                    choices=["DEMO", "PCB1", "PCB2", "PCB3", "PCB4"],
                    default=config_file.get("CONTROLLER_TYPE", None),
                ),
                inquirer.List(
                    "CTRL_MIDI",
                    message="MIDI controller",
                    choices=["TRUE", "FALSE"],
                    default=config_file.get("CTRL_MIDI", None),
                ),
                inquirer.List(
                    "CTRL_OSC",
                    message="OSC controller",
                    choices=["TRUE", "FALSE"],
                    default=config_file.get("CTRL_OSC", None),
                ),
                inquirer.List(
                    "CTRL_HTTP",
                    message="HTTP controller",
                    choices=["TRUE", "FALSE"],
                    default=config_file.get("CTRL_HTTP", None),
                ),
            ]
        )
        self.config_file = self.config_file | runtime_parameters
        self._variables_menu(self.config_file)

    def _advanced_build_options_menu(self, config_file: dict) -> None:
        """This menu will allow the user to modify the advanced build options.
        These are additional build options.

        Args:
            config_file (dict): The Syfal config file
        """
        advanced_build_options = inquirer.prompt(
            [
                inquirer.List(
                    "LINUX",
                    message="Linux",
                    choices=["TRUE", "FALSE"],
                    default=config_file.get("LINUX", None),
                ),
                inquirer.List(
                    "CONFIG_EXPERIMENTAL_TDM",
                    message="Experimental TDM",
                    choices=["TRUE", "FALSE"],
                    default=config_file.get("CONFIG_EXPERIMENTAL_TDM", None),
                ),
                inquirer.List(
                    "CONFIG_EXPERIMENTAL_SIGMA_DELTA",
                    message="Experimental Sigma Delta",
                    choices=["TRUE", "FALSE"],
                    default=config_file.get("CONFIG_EXPERIMENTAL_SIGMA_DELTA", None),
                ),
                inquirer.List(
                    "PREPROCESSOR_HLS",
                    message="Preprocessor HLS",
                    choices=["TRUE", "FALSE"],
                    default=config_file.get("PREPROCESSOR_HLS", None),
                ),
                inquirer.List(
                    "PREPROCESSOR_I2S",
                    message="Preprocessor I2S",
                    choices=["TRUE", "FALSE"],
                    default=config_file.get("PREPROCESSOR_I2S", None),
                ),
                inquirer.Text(
                    "I2S_SOURCE",
                    message="I2S source",
                    default=config_file.get("I2S_SOURCE", None),
                ),
                inquirer.Text(
                    "BD_TARGET",
                    message="BD target",
                    default=config_file.get("BD_TARGET", None),
                ),
            ]
        )
        self.config_file = self.config_file | advanced_build_options
        self._variables_menu(self.config_file)

    def _variables_menu(self, config_file: dict) -> None:
        """This menu will allow the user to modify the variables in the
        Syfala configuration file.

        Args:
            config_file (dict): The syfala config file

        Returns:
            dict: The syfala config file
        """
        answer = inquirer.prompt(
            [
                inquirer.List(
                    "menu",
                    message="What targets?",
                    choices=[
                        "Xilinx related options",
                        "Target",
                        "Board Target",
                        "Runtime parameters",
                        "Advanced build options",
                        "<--- Back",
                    ],
                )
            ]
        ).get("menu", None)

        options = {
            "Xilinx related options": self._xilinx_related_options_menu,
            "Target": self._target_menu,
            "Board Target": self._board_target_menu,
            "Runtime parameters": self._runtime_parameters_menu,
            "Advanced build options": self._advanced_build_options_menu,
            "<--- Back" : self._main_menu,
        }
        if answer == "<--- Back":
            options[answer]()
        else : 
            options[answer](config_file)

    def _build_targets_menu(self, config_file: dict, run_commands: str) -> None:
        """The build targets menu is used to select the build targets.
        It will constitute a list of actions that will be executed when
        the configuration tool exits.

        Args:
            config_file (dict): The syfala config file
            run_commands (str): The actual selected command

        Returns:
            dict: The syfala config file
        """
        answer = inquirer.prompt(
            [
                inquirer.List(
                    "build",
                    message="What targets?",
                    choices=["all","hw", "sw", "bitstream", "synth", "project", "hls", "hls-target-file", "linux", "linux-boot", "linux-root"],
                ),
            ]
        ).get("build", None)
        self.run_commands = "make "+str(answer)
        print(self.run_commands)
        self._main_menu()



    def _write_config_file(self, config_file: dict) -> None:
        """Overwrite the makefile.env file with the new configuration.
        We need to convert from a dictionary to a string and write
        that string to the makefile.env file by overriding the old
        document.

        Args:
            config_file (dict): The syfala config file
        """
        with open(self.config_path, "w") as file:
            for key, value in config_file.items():
                file.write(f"{key} := {value}\n")

    def _main_menu(self) -> None:
        """
        Entry point. This menu is the homepage of the configuration
        tool. The file will be written when the user exits the tool.
        """
        answer = inquirer.prompt(
            [
                inquirer.List(
                    "choice",
                    message="Do you want to modify variables or build targets?",
                    choices=["[°] Variables","  `--> Print Variables Config", "[.] Build Targets", "[o] Start Syfala","[x] Exit"],
                ),
            ]
        )
        if answer.get("choice") == "[°] Variables":
            self.config_file = self._variables_menu(self.config_file)
        elif answer.get("choice") == "  `--> Print Variables Config":
            self._display_config_file(self.config_file)
        elif answer.get("choice") == "[.] Build Targets":
            self.config_file = self._build_targets_menu(self.config_file,self.run_commands)
        elif answer.get("choice") == "[o] Start Syfala":
            print("Syfala running "+self.run_commands)
            os.system('cd /$HOME/syfala-project/; ' + self.run_commands)
            exit(0)
        else:
            print("====> config file saved!")
            self._write_config_file(self.config_file)
            exit(0)

    def run(self):
        self._main_menu()


if __name__ == "__main__":
    # Path for the syfala user configuration file
    PROJECT_DIR = Path.home() / "syfala-project" / "makefile.env"
    app = Tui(PROJECT_DIR)
    app.run()
